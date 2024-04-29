import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:link4launches/logic/api/backup.dart';
import 'package:link4launches/logic/api/requester.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';

/// Class used to manage api requests to the Launch Library 2 API which also manages the backup json file used to store data regarding launches
/// to overcome the api limitation. This class also provide smart reuse of data when performing the subrequestes for each launch in order to
/// perform the smallest amount of request possible.
class LaunchLibrary2API {
  /// The backup file manager.
  late final BackupJsonManager _backupManager;

  /// The link to use in order to perform the api request for the launches.
  final String _linkLL2;

  static const String _countryAPILink = 'https://restcountries.com/v3.1/alpha/';

  final Requester _requesterLL2;

  final Requester _requesterCountry;

  /// The app cotext used to call the [CustomSnackBar].
  final BuildContext context;

  /// Maximum amount of free request to the api.
  static const int _maxRequest = 15;

  LaunchLibrary2API({
    required String link,
    required this.context,
  })  : _linkLL2 = link,
        _requesterLL2 = Requester(link: link),
        _requesterCountry = const Requester(link: _countryAPILink) {
    _backupManager = BackupJsonManager(
      backupFile: 'll2data.json',
      onFileLoadError: () => _callSnackBar('Cannot load backup file'),
    );
  }

  String get link => _linkLL2;

  /// Performs a main request to the api (at ``[_linkLL2]``) to obtain the next ``[limit]`` launches (also may contain latest success, failures or
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
    Map<String, dynamic> body = {};

    await _requesterLL2.get(
      parameters: '&limit=$limit',
      onSuccess: (response) async {
        var data = (_safeDecoding(input: response.bodyBytes, replacingsList: [
          [' | Unknown Payload', '']
        ]) as Map<String, dynamic>);

        int totalLaunchers = 0;
        totalLaunchers = await _addLaunchersData(map: data);

        if (totalLaunchers == 0) {
          _callSnackBar('Unable to load new launches');
          return;
        }

        // Updates the amount of launches in the map, because the api doesn't give the right number
        data['count'] = totalLaunchers;

        _backupManager.writeJsonFile(json.encode(data));
        body = Map<String, dynamic>.from(data);
      },
      onError: (statusCode, reasonPhrase, responseBody) {
        String openBR = '{', closeBR = '}';
        _callSnackBar(
            'Error $statusCode : ${((reasonPhrase != null && reasonPhrase.isNotEmpty) && (responseBody.isNotEmpty)) ? responseBody.replaceAll(openBR, '').replaceAll(closeBR, '').replaceAll('"detail":', '').replaceAll('"', '') : ': due to $reasonPhrase'}');
      },
      onException: () =>
          _callSnackBar('An error occurred while looking for new launches'),
    );

    if (body.isEmpty) {
      return json.decode(await _backupManager.loadStringFromFile());
    }

    return body;
  }

  Future<int> _addLaunchersData({required Map<String, dynamic> map}) async {
    Map<String, Map<String, dynamic>> launcherMap = {};
    Map<String, dynamic> backup = (await _backupManager.fileExists())
        ? json.decode(await _backupManager.loadStringFromFile())
        : {};
    int freeRequestCounter = _maxRequest - 1;
    int totalLaunches = 0;

    for (int i = 0; i < (map['results'] as List).length; i++) {
      String launcherId =
          map['results'][i]['rocket']['configuration']['id'].toString();

      if (launcherMap.containsKey(launcherId)) {
        // This value is already contained in the launcherMap
        map['results'][i]['rocket']['configuration']['url'] =
            launcherMap[launcherId];
      } else if (backup.isNotEmpty &&
          i < (backup['results'] as List).length &&
          (backup['results'][i]['rocket']['configuration']['id'].toString() ==
              launcherId)) {
        // This value is already contained in the backup
        map['results'][i]['rocket']['configuration']['url'] =
            backup['results'][i]['rocket']['configuration']['url'];

        launcherMap.putIfAbsent(launcherId,
            () => map['results'][i]['rocket']['configuration']['url']);
      } else if (freeRequestCounter > 0) {
        // This value isn't contained anywhere else, so an api reuest is needed
        var result = await _fetchLauncherJson(
          launcherLink: map['results'][i]['rocket']['configuration']['url'],
          launcherName: map['results'][i]['rocket']['configuration']
              ['full_name'],
        );

        if (result.containsKey('http_code') &&
            result['http_code'].toString() == '429') {
          freeRequestCounter = 0;
        } else {
          map['results'][i]['rocket']['configuration']['url'] = result;

          // Changes the country code format
          map['results'][i]['rocket']['configuration']['url']['manufacturer']
                  ['country_code'] =
              await _fetchCountryCode(
                  countryCode: map['results'][i]['rocket']['configuration']
                          ['url']['manufacturer']['country_code']
                      .toString());

          launcherMap.putIfAbsent(launcherId,
              () => map['results'][i]['rocket']['configuration']['url']);
          freeRequestCounter--;
        }
      } else {
        /// All the possible launchers data were added to map, so the remaining launches are removed
        for (int j = (map['results'] as List).length - 1;
            j >= totalLaunches;
            j--) {
          (map['results'] as List).removeLast();
        }
        return totalLaunches;
      }
      totalLaunches++;
    }
    return totalLaunches;
  }

  Future<Map<String, dynamic>> _fetchLauncherJson({
    required String launcherLink,
    required String launcherName,
  }) async {
    Map<String, dynamic> data = {};

    await _requesterLL2.get(
      fullLink: launcherLink,
      parameters: '',
      onSuccess: (response) async =>
          data = _safeDecoding(input: response.bodyBytes),
      onError: (statusCode, reasonPhrase, responseBody) {
        String openBR = '{', closeBR = '}';
        _callSnackBar(
            'Error $statusCode : ${((reasonPhrase != null && reasonPhrase.isNotEmpty) && (responseBody.isNotEmpty)) ? responseBody.replaceAll(openBR, '').replaceAll(closeBR, '').replaceAll('"detail":', '').replaceAll('"', '') : ': due to $reasonPhrase for $launcherName'}');
        data['http_code'] = statusCode;
      },
      onException: () => _callSnackBar(
          'An error occurred while looking for $launcherName data'),
    );

    return data;
  }

  /// Takes the cca3 country code (from the main api) and then use https://restcountries.com api to convert it to the cca2 format.
  ///
  /// #### Parameters
  /// - ``String [countryCode]`` : the cca3 country code, e.g. ``USA`` (United States of America).
  ///
  /// #### Returns
  /// ``Future<String>`` : the cca2 country code, e.g. ``'USA'`` --> ``'US'``.
  Future<String> _fetchCountryCode({required String countryCode}) async {
    String cca2 = '';
    await _requesterCountry.get(
      parameters: countryCode,
      onSuccess: (res) async =>
          cca2 = (_safeDecoding(input: res.bodyBytes, replacingsList: [
        ['\r', ''],
        ['\n', '']
      ]) as List)[0]['cca2']
              .toString(),
      onError: (statusCode, reasonPhrase, responseBody) {},
    );

    return cca2;
  }

  /// Reads the byteCode of a http resonse, converts it into an utf8 string and than decodes the JSON in a [Map].
  ///
  /// #### Parameters
  /// - ``Uint8List [input]`` : The byteCode of a http resonse.
  ///
  /// #### Returns
  /// ``Map<String, dynamic>`` : the JSON content converted into a Map.
  _safeDecoding({
    required Uint8List input,
    List<List<String>>? replacingsList,
    bool replaceAll = true,
  }) {
    String str = utf8.decode(input);

    if (replacingsList != null && replacingsList.isNotEmpty) {
      for (var subList in replacingsList) {
        if (subList.length > 1) {
          if (replaceAll) {
            str = str.replaceAll(subList[0], subList[1]);
          } else {
            str = str.replaceFirst(subList[0], subList[1]);
          }
        }
      }
    }

    return json.decode(str);
  }

  /// A simplyfied method to invoke the [CustomSnackBar] using [context].
  ///
  /// #### Parameters
  /// - ``String [message]`` : the textual message to show in the SnackBar.
  void _callSnackBar(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(CustomSnackBar(message: message).build());
}
