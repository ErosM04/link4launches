import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_content.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

/// Class used to update the app to the latest version. Works by looking for new releases in GitHub and downloading the new version in the
/// ``Download`` folder after the user gave the consent (with a [Dialog]).
class Updater {
  /// The actual version of the app (has to be change every release).
  final String actualVersion = '1.0.0';

  /// Link to the GitHub api to get the json containg the latest release data.
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/link4launches/releases/latest';

  /// Link to the apk file of the latest app version in the latest GitHub release.
  final String _latestApkLink =
      'https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk';

  /// Context used to call a [CustomSnackBar].
  final BuildContext context;

  const Updater(this.context);

  /// Uses ``[_getLatestVersionData]`` to get a [Map] containing the latest version id and the latest changes. If the latest version is
  /// different from the actual version, asks for update consent to the user using [_invokeDialog] to invoke a [CustomDialog].
  Future updateToNewVersion() async {
    // var data = await _getLatestVersionData();

    // if (data.isNotEmpty && (data['version'].toString() != actualVersion)) {
    //   _invokeDialog(
    //     latestVersion: data['version'].toString(),
    //     content: DialogContent(
    //       latestVersion: data['version'].toString(),
    //       changes: data['description'].toString(),
    //     ),
    //   );
    // }
    _downloadUpdate('1.1.0');
  }

  /// Performs a request to the Github API to obtain a json about the latest release data.
  /// If anything goes wrong an [Exception] is thrown and an error message [CustomSnackBar] is called.
  ///
  /// #### Returns
  /// ``Future<Map<String, String>>`` : a map containing both the latest version and the changes.
  ///
  /// E.g.:
  /// ```
  /// {
  ///   'version' : '1.0.0',
  ///   'description' : '...'
  /// }
  /// ```
  Future<Map<String, String>> _getLatestVersionData() async {
    int? statusCode;

    try {
      var response = await http.get(Uri.parse(_latestReleaseLink));
      statusCode = response.statusCode;

      if (statusCode == 200) {
        var data = json.decode(response.body);
        return {
          'version': data['tag_name'].toString().replaceAll('v', ''),
          'description': data['body'].toString(),
        };
      } else {
        throw Exception();
      }
    } on Exception catch (_) {
      _callSnackBar(
          message:
              'Errore ${statusCode ?? ''} durante la ricerca di una nuova versione');
      return {};
    }
  }

  /// Uses ``[showGeneralDialog]`` to show a [CustomDialog] over the screen using both a fade and a slide animation.
  ///
  /// #### Parameters
  /// - ``String [latestVersion]`` : the latest version available for the app.
  /// - ``DialogContent [content]`` : the content to insert below the title in the [CustomDialog].
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

  /// Infroms the user that the download started with a [CustomSnackBar] and uses the ``[FileDownloader]`` object to downlaod the apk.
  /// A [CustomSnackBar] is shown at the end of the download to inform the user that the app has been downloaded and saved
  /// in the ``Downloads`` folder. In case of error an error message [CustomSnackBar] is shown. To show the [CustomSnackBar]
  /// ``[_callSnackBar]`` method is used.
  Future<void> _downloadUpdate(String latestVersion) async {
    _callSnackBar(
        message: 'Download of Link4Launches v$latestVersion has started');

    FileDownloader.downloadFile(
      url: _latestApkLink.trim(),
      onDownloadCompleted: (path) =>
          _installUpdate(latestVersion: latestVersion, path: path),
      onDownloadError: (errorMessage) => _callSnackBar(
        message: 'Error while downloading $latestVersion: $errorMessage',
        durationInSec: 3,
      ),
    );
  }

  /// Install the downloaded apk
  Future _installUpdate(
      // Informs the user that the download ended and where he can find the file.
      {required String latestVersion,
      required String path}) async {
    _callSnackBar(
      message: 'Version $latestVersion downloaded at ${_getShortPath(path)}',
      durationInSec: 5,
    );

    // Removes the '/' at the start of the path, otherwise it would be wrong
    var result = await OpenFilex.open(path.substring(1));

    if (result.type != ResultType.done) {
      _callSnackBar(
        message: 'Error while installing the upload, code: ${result.message}',
        durationInSec: 4,
      );
    }
    // storage/emulated/0/Download/link4launches.apk
  }

  /// Returns a short path form (oly last 2) for [CustomSnackBar] message.
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
