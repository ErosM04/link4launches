import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:link4launches/pages/ui_components/snackbar.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:link4launches/updater/custom_dialog.dart';
import 'package:link4launches/updater/dialog_content.dart';

/// Can be used to update the app, by downloading the new version in the ``Download`` folder after
/// the user gave the consent (with a dialog).
class Updater {
  final String actualVersion = '1.6.1';
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/link4launches/releases/latest';
  final String _latestAPKLink =
      'https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk';
  final BuildContext context;

  const Updater(this.context);

  /// Uses ``[_getLatestVersionJson]`` to get the latest version and if it is different from the actual version, asks for update consent
  /// to the user. When asking for consent uses ``[_getLatestVersionJson]`` again to get info about the latest changes and insert them
  /// into the dialog using [DialogContent].
  Future updateToNewVersion() async {
    String latestVersion =
        (await _getLatestVersionJson('tag_name')).replaceAll('v', '');

    if (latestVersion != actualVersion && latestVersion.isNotEmpty) {
      _invokeDialog(
        latestVersion: latestVersion,
        content: DialogContent(
            latestVersion: latestVersion,
            changes: await _getLatestVersionJson('body')),
      );
    }
  }

//   Future updateToNewVersion() async {
//     String latestVersion = '1.6.2';

//     if (latestVersion != actualVersion && latestVersion.isNotEmpty) {
//       _invokeDialog(
//         latestVersion: latestVersion,
//         content: DialogContent(latestVersion: latestVersion, changes: """
// ## link4launches v1.5.0

// ### Features
// - Changed app name and name displayed in appbar from ``link4launches`` to ``Link4Launches``
// - Introduced the ``Update`` functionality which, every time the app starts, verifies if the actual version is behind the latest release and than proceeds to download the update (apk file), more info in the readme
// - Added ``Storage access`` permission request to allow the app to download the update file
// - Set default duration of the ``Snackbars`` to 3 seconds

// ### Changes
// - Modified updater code
// - Introduced a new grapich for updater which is super cool dude!
// - Modfied images code in order to zoom in
// - bla bla bla

// ### Bug fixes
// - fixed bug regarding ``FAILURE`` status color, which was read as undefined value and colored blue instead of red
// - modified error message (displayed with a ``Snackbar``) for the api
// - modified caching animation duration
// """),
//       );
//     }
//   }

  /// Performs a request to the Github API to obtain a json about the latest release data.
  /// If anything goes wrong an [Exception] is thrown and an error message [SnackBar] is called.
  /// #### Parameters
  /// - ``String [key]`` : is the key used to get the corressponding value from the json ``{['key'] => value}``.
  ///
  /// #### Returns
  /// ``Future<String>`` : the value corresponding to ``[key]`` in the json.
  Future<String> _getLatestVersionJson(String key) async {
    int statusCode = -1;

    try {
      var response = await http.get(Uri.parse(_latestReleaseLink));
      statusCode = response.statusCode;

      if (statusCode == 200) {
        var data = json.decode(response.body);
        return data[key].toString();
      } else {
        throw Exception();
      }
    } on Exception catch (_) {
      _callSnackBar(
          message:
              'Errore $statusCode durante la ricerca di una nuova versione');
    }

    return '';
  }

  /// Uses ``[showGeneralDialog]`` to show an [AlertDialog] over the screen.
  /// #### Parameters
  /// - ``String [latestVersion]`` : the latest version available of the app.
  /// - ``DialogContent [context]`` : the content to insert under the title in the [AlertDialog].
  void _invokeDialog({
    required String latestVersion,
    required DialogContent content,
  }) =>
      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
        transitionDuration: const Duration(milliseconds: 180),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0.0, 0.5), end: Offset.zero)
                    .animate(animation),
                child: FadeTransition(
                    opacity:
                        Tween<double>(begin: 0.5, end: 1).animate(animation),
                    child: CustomDialog(
                      iconPath: 'assets/upgrade.png',
                      title: 'New version available',
                      denyButtonText: 'No',
                      confirmButtonText: 'Yes',
                      denyButtonAction: () {
                        _callSnackBar(message: ':(');
                        Navigator.pop(context);
                      },
                      confirmButtonAction: () {
                        _downloadUpdate(latestVersion);
                        Navigator.pop(context);
                      },
                      child: content,
                    ))),
      );

  /// Infroms the user that the download started with a [SnackBar] and uses the ``[FileDownloader]`` object to downlaod the apk.
  /// A [SnackBar] is shown at the end of the download to inform the user that the app has been downloaded and saved
  /// in the ``Downloads`` folder. In case of error an error message [SnackBar] is shown. To show the snackbar
  /// ``[_callSnackBar]`` method is used.
  Future<void> _downloadUpdate(String latestVersion) async {
    _callSnackBar(
        message: 'Download of Link4Launches v$latestVersion has started');

    FileDownloader.downloadFile(
      url: _latestAPKLink.trim(),
      onDownloadCompleted: (path) => _callSnackBar(
          message:
              'Version $latestVersion downloaded at ${path.split('/')[4]}/${path.split('/').last}',
          durationInSec: 5),
      onDownloadError: (errorMessage) => _callSnackBar(
          message: 'Error while downloading $latestVersion: $errorMessage',
          durationInSec: 3),
    );
  }

  /// Function used to simplify the invocation and the creation of a ``[SnackBar]``.
  void _callSnackBar(
          {required String message,
          int durationInSec = 2,
          int? durationInMil}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBarMessage(
              message: message,
              durationInSec: durationInSec,
              durationInMil: durationInMil)
          .build(context));
}
