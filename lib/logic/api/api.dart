import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:link4launches/logic/api/backup.dart';
import 'package:link4launches/logic/api/requester.dart';
import 'package:link4launches/model/launches.dart';
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

  /// Maximum amount of free request to the api.
  static const int _maxRequest = 15;

  final Requester _requesterCountry;

  /// The app cotext used to call the [CustomSnackBar].
  final BuildContext context;

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
  Future<Launches> launch(int limit) async {
    Launches launches = Launches.empty(availableRequests: _maxRequest);

    await _requesterLL2.get(
      parameters: '&limit=$limit',
      onSuccess: (response) async {
        launches.updateData =
            (_safeDecoding(input: response.bodyBytes, replacingsList: [
          [' | Unknown Payload', '']
        ]) as Map<String, dynamic>);

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

  Future<void> _addLaunchersData({required Launches launches}) async {
    Map<String, Map<String, dynamic>> launcherMap = {};
    Launches backup = (await _backupManager.fileExists())
        ? Launches(
            availableRequests: 0,
            data: json.decode(await _backupManager.loadStringFromFile()),
          )
        : Launches.empty(availableRequests: 0);
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
