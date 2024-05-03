import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:link4launches/logic/api/backup.dart';
import 'package:link4launches/logic/api/requester.dart';
import 'package:link4launches/model/launches.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';

/// Class used to manage API requests to the Launch Library 2 API which also manages the backup json file used to store data regarding launches
/// to overcome the api limitation. This class also provide smart reuse of data when performing the subrequestes for each launch in order to
/// perform the smallest amount of requests possible.
class LaunchLibrary2API {
  /// The backup file manager.
  late final BackupJsonManager _backupManager;

  /// The link to use in order to perform the API request for the launches.
  static const String _linkLL2 =
      'https://ll.thespacedevs.com/2.2.0/launch/upcoming/?format=json';

  // The link of the API used to translate cca3 country code to the cca2 version.
  static const String _countryAPILink = 'https://restcountries.com/v3.1/alpha/';

  // The object used to perform request to the Launch Library 2 API.
  final Requester _requesterLL2;

  /// Maximum amount of free request to the LL2 API.
  static const int _maxRequest = 15;

  // The object used to perform request to the Country Code API.
  final Requester _requesterCountry;

  /// The app context used to call the [CustomSnackBar].
  final BuildContext context;

  LaunchLibrary2API({
    required this.context,
  })  : _requesterLL2 = const Requester(link: _linkLL2),
        _requesterCountry = const Requester(link: _countryAPILink) {
    _backupManager = BackupJsonManager(
      backupFile: 'll2data.json',
      onFileLoadError: () => _callSnackBar('Cannot load backup file'),
    );
  }

  /// The link used to access to the Launch Library 2 API.
  String get link => _linkLL2;

  /// Performs a main request to the api (at ``[_linkLL2]``) to obtain the next ``[_maxRequest]`` launches (also may contain
  /// latest successes, failures or in progress launches) as a json. To perform the request the ``[_requesterLL2]`` object is used.
  ///
  /// If the request is successful the data is saved in a [Launches] object.
  /// Than uses ``[_addLaunchersData]`` to get the data of each launcher.
  ///
  /// Everything is than saved in a backup json file using ``[_backupManager]``. If anything goes wrong a [CustomSnackBar] is called
  /// and the pre-existing backup file is returned. The data are always managed by the [Launches] object.
  ///
  /// #### Parameters
  /// - ``int [limit]`` : the amount of launch requested in the main request (for every launch than a 2nd request may performed in
  /// [_addLaunchersData]).
  ///
  /// #### Returns
  /// ``Future<Launches>`` : the ``[Launches]`` object containing all the data of each launch.
  Future<Launches> launch(int limit) async {
    Launches launches = Launches.empty(availableRequests: _maxRequest);

    await _requesterLL2.get(
      parameters: '&limit=$limit',
      onSuccess: (response) async {
        launches.updateData =
            _safeDecoding(input: response.bodyBytes, replacingsList: [
          [' | Unknown Payload', '']
        ]);

        await _addLaunchersData(launches: launches);

        if (launches.totalLaunches == 0) {
          _callSnackBar('Unable to load new launches');
          launches.clearData();
          return;
        }
        launches.decreaseRequests();

        _backupManager.writeJsonFile(json.encode(launches.fullData));
      },
      onError: (statusCode, reasonPhrase, responseBody) {
        String openBR = '{', closeBR = '}';
        if (statusCode == 429) {
          _callSnackBar('Error $statusCode : free request exhausted');
        } else {
          _callSnackBar(
              'Error $statusCode : ${((reasonPhrase != null && reasonPhrase.isNotEmpty) && (responseBody.isNotEmpty)) ? responseBody.replaceAll(openBR, '').replaceAll(closeBR, '').replaceAll('"detail":', '').replaceAll('"', '') : ': due to $reasonPhrase'}');
        }
        launches.setRequestsToZero();
        launches.clearData();
      },
      onException: () {
        _callSnackBar('An error occurred while looking for new launches');
        launches.setRequestsToZero();
        launches.clearData();
      },
    );

    if (launches.isEmpty) {
      launches.updateData =
          json.decode(await _backupManager.loadStringFromFile());
    }

    return launches;
  }

  /// Adds to the ``[launches]`` the missing data for each launcher. To avoid wasting the requests the data is saved
  /// in a [Map] where the key is the id of the launcher and the corresponding value is the [Map] containg the data; every
  /// time that a launcher with the same id needs the data, the [Map] is used.
  ///
  /// In order to minimize the requests performed to the API this method also uses the launchers data contained in the
  /// ``[_backupManager]``.
  ///
  /// If the data aren't contained neither in the [Map] nor in the backup, a request to the API si performed using the
  /// method ``[_fetchLauncherJson]``. If this request returns the error ``429`` the available free requests are set to 0,
  /// otherwise the new data are saved in the [launches] object (before saving the data the country code is modifyed using
  /// ``[_fetchCountryCode]``).
  ///
  /// #### Parameters
  /// - ``Launches [launches]`` : the object where the data about the launches are saved.
  Future<void> _addLaunchersData({required Launches launches}) async {
    Map<String, Map<String, dynamic>> launcherMap = {};
    Launches backup = (await _backupManager.fileExists())
        ? Launches(
            availableRequests: 0,
            data: json.decode(await _backupManager.loadStringFromFile()),
          )
        : Launches.empty(availableRequests: 0);
    // Keeps track of the launches for which data could be retrived (to later discard the remaining ones).
    int usableLaunches = 0;

    for (int i = 0; i < launches.totalLaunches; i++) {
      String launcherId = launches.getLauncherId(i);

      if (launcherMap.containsKey(launcherId)) {
        // This value is already contained in the launcherMap
        launches.addLauncherData(i,
            data: (launcherMap[launcherId] as Map<String, dynamic>));
      } else if (backup.isNotEmpty &&
          i < launches.totalLaunches &&
          (backup.getLauncherId(i) == launcherId)) {
        // This value is already contained in the backup
        launches.addLauncherData(i, data: backup.getLauncherData(i));
        launcherMap.putIfAbsent(launcherId, () => launches.getLauncherData(i));
      } else if (launches.remainingRequests > 0) {
        // This value isn't contained anywhere else, so an api request is needed
        var result = await _fetchLauncherJson(
          launcherLink: launches.getLauncherUrl(i),
          launcherName: launches.getLauncherFullName(i),
        );

        if (result.containsKey('http_code') &&
            result['http_code'].toString() == '429') {
          // Error 429: free requests to the api exhausted
          launches.setRequestsToZero();
        } else {
          // Request was successful
          launches.addLauncherData(i, data: result);

          // Changes the country code format
          launches.setLauncherCountryCode(i,
              newCC: await _fetchCountryCode(
                  countryCode: launches.getLaunchManCountryCode(i)));

          launcherMap.putIfAbsent(
              launcherId, () => launches.getLauncherData(i));
        }
      } else {
        /// All the possible launchers data were added to map, so the remaining launches are removed
        for (int j = launches.totalLaunches - 1; j >= usableLaunches; j--) {
          launches.getLaunchesList().removeLast();
        }
        return;
      }
      usableLaunches++;
    }
  }

  /// Uses the ``[_requesterLL2]`` object to retrive data about a launcher.
  /// If the request is successful the data are returned. If an error occurs the error code is saved in the [Map] and
  /// than returned. In the end ig an exception is thrown the retruned value is an empty [Map].
  ///
  /// #### Parameters
  /// - ``String [launcherLink]`` : the link used to perform the request;
  /// - ``String [launcherName]`` : the name used in the ``[CustomSnackBar]``;
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
        if (statusCode != 429) {
          _callSnackBar(
              'Error $statusCode : ${((reasonPhrase != null && reasonPhrase.isNotEmpty) && (responseBody.isNotEmpty)) ? responseBody.replaceAll(openBR, '').replaceAll(closeBR, '').replaceAll('"detail":', '').replaceAll('"', '') : ': due to $reasonPhrase for $launcherName'}');
        }
        data['http_code'] = statusCode;
      },
      onException: () => _callSnackBar(
          'An error occurred while looking for $launcherName data'),
    );

    return data;
  }

  /// Takes the ``cca3`` country code (from the main api) and then use the https://restcountries.com api to convert
  /// it to the ``cca2`` format. This function is used as the api that takes the country code and returns the flag
  /// image use the cca2 format.
  ///
  /// To perform the request uese the ``[_requesterCountry]`` object.
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
      onSuccess: (res) {
        // Doesn't use _safeDecoding() because after its execution the newxt code is skipped and the
        // executions skips to end of the .get() function.
        cca2 = json.decode(utf8.decode(res.bodyBytes))[0]['cca2'].toString();
        // This is necessary as onSuccess requires a an async function to be retunred (fix in future)
        fun() async => {};
        return fun();
      },
      onError: (statusCode, reasonPhrase, responseBody) {},
    );

    return cca2;
  }

  /// Reads the byteCode of a http resonse, converts it into an ``utf8`` [String] and than decodes the JSON in a [Map].
  /// It also uses a [List] where each element is [List] of 2 [String] elements, the first is the one to replace and the
  /// second is the one to use as a replacement in the [String] before converting it to a JSON.
  ///
  /// E.g.:
  /// ```
  /// _safeDecoding(input : '{"abcd(f)g" : "cacca"}', replacingsList : [['(', ''], [')', '']],);
  /// // Result: {"abcdfg" : "cacca"}
  /// ```
  ///
  /// #### Parameters
  /// - ``Uint8List [input]`` : The byteCode of a http resonse.
  /// - ``List<List<String>>? replacingsList`` : The list contain a diffrent lists of 2 elements, the first is the one to
  /// replace and the second is the one to use as a replacement.
  ///
  /// #### Returns
  /// ``Map<String, dynamic>`` : the JSON content converted into a Map.
  Map<String, dynamic> _safeDecoding({
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
