import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:link4launches/view/pages/ui_components/snackbar.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:link4launches/logic/updater/custom_dialog.dart';
import 'package:link4launches/logic/updater/dialog_content.dart';

/// Can be used to update the app, by downloading the new version in the ``Download`` folder after
/// the user gave the consent (with a dialog).
class Updater {
  final String actualVersion = '1.6.0';
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/link4launches/releases/latest';
  final String _latestAPKLink =
      'https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk';
  final BuildContext context;

  const Updater(this.context);

  /// Uses ``[_getLatestVersionData]`` to get a [Map] containing the latest version and the latest changes. If the latest version is different
  /// from the actual version, asks for update consent to the user using [_invokeDialog] to invoke a [CustomDialog].
  Future updateToNewVersion() async {
    var data = await _getLatestVersionData();
    if (data.isEmpty) return;

    if (data['version'].toString() != actualVersion) {
      _invokeDialog(
        latestVersion: data['version'].toString(),
        content: DialogContent(
          latestVersion: data['version'].toString(),
          changes: data['body'].toString(),
        ),
      );
    }
  }

  /// Performs a request to the Github API to obtain a json about the latest release data.
  /// If anything goes wrong an [Exception] is thrown and an error message [SnackBar] is called.
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
  /// #### Parameters
  /// - ``String [latestVersion]`` : the latest version available for the app.
  /// - ``DialogContent [context]`` : the content to insert below the title in the [CustomDialog].
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
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
              message: message,
              durationInSec: durationInSec,
              durationInMil: durationInMil)
          .build());
}
