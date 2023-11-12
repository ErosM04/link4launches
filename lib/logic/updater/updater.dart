import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:link4launches/logic/updater/installer.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_builder.dart';
import 'package:link4launches/view/updater/updater_dialog_content.dart';

/// Class used to update the app to the latest version. Works by looking for new releases in GitHub and downloading the new version in the
/// ``Download`` folder after the user gave the consent (with a [CustomDialog]).
class Updater {
  /// The actual version of the app (``!!! has to be change every release !!!``).
  final String actualVersion = '1.0.0';

  /// Link to the GitHub api to get the json containg the latest release data.
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/link4launches/releases/latest';

  /// Link to the apk file of the latest app version in the latest GitHub release.
  final String _latestApkLink =
      'https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk';

  /// Context used to call both the [CustomSnackBar] and the [CustomDialog].
  final BuildContext context;

  const Updater(this.context);

  /// Uses ``[_getLatestVersionData]`` to get a [Map] containing the latest version id and the latest changes. If the latest version is
  /// different from the actual version, asks for update consent to the user using [_invokeDialog] to invoke a [CustomDialog].
  Future updateToNewVersion() async {
    var data = await _getLatestVersionData();

    if (data.isNotEmpty &&
        (data['version'].toString() != actualVersion && !data['draft'])) {
      if (data['prerelease']) {
        // It's a prerelease
        DialogBuilder(context).invokePrereleaseUpdateDialog(
          latestVersion: data['version'].toString(),
          content: UpdaterDialogContent(
            latestVersion: data['version'].toString(),
            changes: data['description'].toString(),
          ),
          denyButtonAction: () => _callSnackBar(message: ':('),
          confirmButtonAction: () =>
              _downloadUpdate(data['version'].toString()),
        );
      } else {
        // It's a normal update
        DialogBuilder(context).invokeUpdateDialog(
          latestVersion: data['version'].toString(),
          content: UpdaterDialogContent(
            latestVersion: data['version'].toString(),
            changes: data['description'].toString(),
          ),
          denyButtonAction: () => _callSnackBar(message: ':('),
          confirmButtonAction: () =>
              _downloadUpdate(data['version'].toString()),
        );
      }
    }
    // _downloadUpdate('1.1.0');
  }

  /// Performs a request to the Github API to obtain a json about the latest release data, the link used is ``[_latestReleaseLink]``.
  /// If anything goes wrong an [Exception] is thrown and an error message [CustomSnackBar] is called.
  ///
  /// #### Returns
  /// ``Future<Map<String, String>>`` : a map containing both the latest version and the changes.
  /// Returns an empty map if any error occurs.
  ///
  /// E.g.:
  /// ```
  /// {
  ///   'version' : '1.0.0',
  ///   'description' : '...'
  /// }
  /// ```
  Future<Map<String, dynamic>> _getLatestVersionData() async {
    int? statusCode;

    try {
      var response = await http.get(Uri.parse(_latestReleaseLink));
      statusCode = response.statusCode;

      if (statusCode == 200) {
        var data = json.decode(response.body);
        return {
          'version': data['tag_name'].toString().replaceAll('v', ''),
          'description': data['body'].toString(),
          'draft': data['draft'],
          'prerelease': data['prerelease'],
          // 'prerelease': true,
        };
      } else {
        throw Exception();
      }
    } on Exception catch (_) {
      _callSnackBar(
          message: 'Error ${statusCode ?? ''} while looking for updates');
      return {};
    }
  }

  /// Infroms the user that the download started with a [CustomSnackBar] and uses the ``[FileDownloader]`` object to downlaod the apk.
  /// If the download completed successfully a [CustomSnackBar] is shown to inform the user that the app file (.apk) has been downloaded
  /// and saved in the ``Downloads`` folder. Then the file is installed using the ``[Installer]`` object.
  /// Otherwise whether the download failed, a [CustomSnackBar] with an error message is shown.
  /// To show the [CustomSnackBar] ``[_callSnackBar]`` method is used.
  ///
  /// In order for the [Installer] to be able to properly open the path, the '/' character at the start of the path is removed.
  /// E.g. ``/storage/emulated/0/Download/link4launches.apk`` --> ``storage/emulated/0/Download/link4launches.apk``
  Future<void> _downloadUpdate(String latestVersion) async {
    _callSnackBar(
        message: 'Download of Link4Launches v$latestVersion has started');

    FileDownloader.downloadFile(
      url: _latestApkLink.trim(),
      onDownloadCompleted: (path) {
        _callSnackBar(
          message:
              'Version $latestVersion downloaded at ${_getShortPath(path)}',
          durationInSec: 5,
        );
        Future.delayed(
          const Duration(seconds: 5),
          () => Installer(context)
            ..installUpdate((path.startsWith('/')) ? path.substring(1) : path),
        );
      },
      onDownloadError: (errorMessage) => _callSnackBar(
        message: 'Error while downloading $latestVersion: $errorMessage',
        durationInSec: 3,
      ),
    );
  }

  /// Returns a short path format (only last 2 positions). Used for [CustomSnackBar] message.
  /// E.g.: ``storage/emulated/0/Download/link4launches.apk`` --> ``Download/link4launches.apk``
  String _getShortPath(String path, {String splitCarachter = '/'}) =>
      '${path.split(splitCarachter)[path.split(splitCarachter).length - 2]}/${path.split(splitCarachter).last}';

  /// Function used to simplify the invocation of a ``[CustomSnackBar]``.
  void _callSnackBar(
          {required String message,
          int durationInSec = 2,
          int? durationInMil}) =>
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
              message: message,
              durationInSec: durationInSec,
              durationInMil: durationInMil)
          .build());
}
