import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:link4launches/logic/api/backup.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'dart:convert';

/// Class used to manage api requests to the Launch Library 2 API which also manages the backup json file used to store data regarding launches
/// to overcome the api limitation. This class also provide smart reuse of data when performing the subrequestes for each launch in order to
/// perform the smallest amount of request possible.
class LaunchLibrary2API {
  /// The backup file manager.
  late final BackupJsonManager _backupManager;

  /// The link to use in order to perform the api request for the launches.
  final String link;

  /// The app cotext used to call the [CustomSnackBar].
  final BuildContext context;

  LaunchLibrary2API({
    required this.link,
    required this.context,
  }) {
    _backupManager = BackupJsonManager(
      backupFile: 'll2data.json',
      onFileLoadSuccess: () => _callSnackBar('Data loaded from backup file'),
      onFileLoadError: () => _callSnackBar('Cannot load backup file'),
    );
  }

  /// Performs a main request to the api (at ``[link]``) to obtain the next ``[limit]`` launches (also may contain latest success, failures or
  /// in progress launches) as a json. Than for each launch performs another request using the ``[_fetchAllRocketData]`` method to obtain
  /// information about the launcher.
  /// Everything is than saved in a backup json file using ``[_backupManager]``. If anything goes wrong a [CustomSnackBar] is called and the
  /// pre-existing backup file is returned.
  ///
  /// #### Parameters
  /// - ``int [limit]`` : the amount of launch requested in the main request (for every launch than a 2nd request is performed in [_fetchAllRocketData]).
  ///
  /// #### Returns
  /// ``Future<Map<String, dynamic>>`` : the map containing all the data of each launch. The list of launches is stored at the voice ``map['result']``.
  Future<Map<String, dynamic>> launch(int limit) async {
    int? statusCode;
    String? reasonPhrase, body;

    try {
      var response = await http.get(Uri.parse('$link&limit=$limit'));

      if (response.statusCode == 200) {
        var data = json.decode(convertGibberish(response.body));
        int launchAmount = _getLaunchAmount(data);
        data['count'] = launchAmount; //Sets the right number of launches
        data = await _fetchAllRocketData(data, launchAmount);
        _backupManager.writeJsonFile(json.encode(data));
        return data;
      } else {
        statusCode = response.statusCode;
        reasonPhrase = response.reasonPhrase ?? '';
        body = response.body;
        throw Exception();
      }
    } on Exception catch (_) {
      // Throttled request (15 requests limit per hour exceeded), reads backup file
      _callSnackBar(
          'Error${(statusCode != null) ? ' $statusCode' : ''} ${((reasonPhrase != null && reasonPhrase.isNotEmpty) && (body != null && body.isNotEmpty)) ? body.replaceAll('{', '').replaceAll('}', '').replaceAll('"detail":', '').replaceAll('"', '') : ': due to $reasonPhrase'}');
    }

    return json.decode(await _backupManager.loadStringFromFile());
  }

  /// Use a for to perform requests for each launch contained in ``[map]``, while ``[totalLaunches]`` is the amount of launches in the map.
  /// The fetch to the api is used to retrive data regarding the configuration, compreeding both launcher and company/agency.
  ///
  /// To be more precise this method doesn't perform a request for each launch, but, as the api has limited request, tries to reuse
  /// data from backup json file or previusly fetched data (during for execution).
  ///
  /// #### Parameters
  /// - ``Map<String, dynamic> [map]`` : the map with all the launches, the configuration link for the api request has to be located at
  /// ``map['results'][i]['rocket']['configuration']['url']``;
  /// - ``int [totalLaunches]`` : the amount of launches contained in the map at the voice ``map['results']``.
  ///
  /// #### Returns
  /// ``Future<Map<String, dynamic>>`` : the fina map containing with every launch also containing conf. data.
  Future<Map<String, dynamic>> _fetchAllRocketData(
      Map<String, dynamic> map, int totalLaunches) async {
    Map<String, dynamic> backup = {};
    try {
      // In this case in not necessary to show the SncakBar
      backup = json.decode(
          await _backupManager.loadStringFromFile(showSuccessSnackBar: false));
    } on Exception catch (_) {
      backup = {};
    }

    try {
      // USed to save the link that has been alredy used in a requesto, to avoid wasting api calls
      List<dynamic> linkList = [];

      for (int i = 0; i < totalLaunches; i++) {
        // Uses data from backup if the actual rocket configuration is already contained in the backup json file.
        // Otherwise if the data are not contained, but the fetch was already performed (during the for execution), reuse those data.
        // If the data are not containd in the backup and this link wasn't already used in an api request, then a new api request is performed.
        var link = map['results'][i]['rocket']['configuration']['url'];
        int pos = _findRecurrence(linkList, link);
        /*
          The first if is used to check if the element in the map at pos is equal to element at backup at the same pos. With this method
          is possible to reuse data from backup. As the if works on 2 elements at the same position (on in map and one in backup)
          whenever an element is removed (because the launch occured or was just removed), the backup loading won't work because all the
          elements are going to move of one position, and by doing so is possible refresh launcher configuration data, which otherwise
          will remain always the same.
          The else if is used to check whether the request to the api for the launcher configuration was already performed and so we already
          have those data.
          The last option (else) occur when the only thing we can do is perform a request to the api (and save the used link in the list).
        */
        if (backup.isNotEmpty &&
            i < backup['count'] &&
            backup['results'][i]['rocket']['configuration']['id'] ==
                map['results'][i]['rocket']['configuration']['id'] &&
            backup['results'][i]['rocket']['configuration']['url'] !=
                map['results'][i]['rocket']['configuration']['url']) {
          map['results'][i]['rocket']['configuration']['url'] =
              backup['results'][i]['rocket']['configuration']['url'];
        } else if (pos != -1) {
          map['results'][i]['rocket']['configuration']['url'] =
              map['results'][pos]['rocket']['configuration']['url'];
        } else {
          var res = await http.get(Uri.parse(link));
          try {
            if (res.statusCode == 200) {
              map['results'][i]['rocket']['configuration']['url'] =
                  json.decode(convertGibberish(res.body));

              // Changes the country code format
              map['results'][i]['rocket']['configuration']['url']
                      ['manufacturer']['country_code'] =
                  await _fetchCountryCode(map['results'][i]['rocket']
                              ['configuration']['url']['manufacturer']
                          ['country_code']
                      .toString());
            } else {
              throw Exception();
            }
          } on Exception catch (_) {
            _callSnackBar(
                'Error: ${res.statusCode} ${(res.reasonPhrase!.isEmpty) ? '' : 'due to ${res.reasonPhrase} '}for ${map['results'][i]['rocket']['configuration']['full_name']}');
          }
        }

        // Adds a link to the list of all link already used in an api call, in order to avoid performing redundant fetches
        linkList.add(link);
      }
    } on Exception catch (_) {
      _callSnackBar('Cannot load launchers data');
    }
    return map;
  }

  /// Takes the cca3 country code (from the main api) and then use https://restcountries.com api to convert it to the cca2 format.
  ///
  /// #### Parameters
  /// - ``String [countryCode]`` : the cca3 country code, e.g. ``USA`` (United States of America).
  ///
  /// #### Returns
  /// ``Future<String>`` : the cca2 country code, e.g. ``'USA'`` --> ``'US'``.
  Future<String> _fetchCountryCode(String countryCode) async {
    try {
      var response = await http
          .get(Uri.parse('https://restcountries.com/v3.1/alpha/$countryCode'));

      if (response.statusCode == 200) {
        return json
            .decode(response.body.replaceAll("\r", "").replaceAll("\n", ""))[0]
                ['cca2']
            .toString();
      } else {
        throw Exception();
      }
    } on Exception catch (_) {
      return '';
    }
  }

  /// Checks if ``[element]`` is contained inside ``[list]``, and returns the position. -1 is returned if ``[element]`` isn't contained.
  ///
  /// #### Parameters
  /// - ``List [list]`` : the list of elements;
  /// - ``[element]`` : the specific element in the list to look for.
  ///
  /// #### Returns
  /// ``int`` : either the position of ``[element]`` in the list, or ``-1`` if there isn't any occurrence.
  int _findRecurrence(List list, element) {
    for (int i = 0; i < list.length; i++) {
      if (list[i] == (element)) {
        return i;
      }
    }
    return -1;
  }

  /// Returns the amount of elements contained in ``[data]``.
  ///
  /// #### Parameters
  /// - ``Map<String, dynamic> [data]`` : the map with the list at ``data['results]``.
  ///
  /// #### Returns
  /// ``int`` : the amount of elements in the list.
  int _getLaunchAmount(Map<String, dynamic> data) {
    int tot = 0;
    try {
      for (int i = 0; i < data['count']; i++) {
        if (data['results'][i] != null) tot += 1;
      }
    } on Error catch (_) {}
    return tot;
  }

  /// Retuns ``[str]`` but removing all unwanted characters.
  ///
  /// #### Parameters
  /// - ``String [str]`` : the string with the unwanted characters.
  ///
  /// #### Returns
  /// ``String`` : the string without the unwanted characters.
  String convertGibberish(String str) => str
      .replaceAll("\r", "")
      .replaceAll("\n", "")
      .replaceAll('Ã©', 'é')
      .replaceAll(' | Unknown Payload', '')
      .replaceAll('â', '–')
      .replaceAll('Î±', 'α');

  /// A simplyfied method to invoke the [CustomSnackBar] using [context].
  ///
  /// #### Parameters
  /// - ``String [message]`` : the textual message to show in the SnackBar.
  void _callSnackBar(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(CustomSnackBar(message: message).build());
}
