import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:link4launches/snackbar.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class Updater {
  final String actualVersion = '1.5.0';
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/link4launches/releases/latest';
  final String _latestAPKLink =
      'https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk';
  final BuildContext context;
  String? _newVersion;

  Updater({required this.context});

  /// Performs a request to the Github API to verify the the latest version of the app,
  /// if the version is ahead then returns ``true``, otherwise display an error ``SnackBar`` and returns ``false``.
  Future<bool> checkForUpdate() async {
    int statusCode = -1;

    try {
      var response = await http.get(Uri.parse(_latestReleaseLink));

      statusCode = response.statusCode;
      if (statusCode == 200) {
        var data = json.decode(response.body);
        _newVersion = data['tag_name'];
        return ('v$actualVersion' != data['tag_name']) ? true : false;
      }
    } on Exception catch (_) {}

    _callSnackBar(
        message: 'Error $statusCode: while looking for the latest version');
    return false;
  }

  /// After 2 seconds shows a ``SnackBar`` to inform the user that the new version has been detected.
  /// Two seconds later downloads the latest version of the app (link4launches.apk) and save it in the Downloads folder.
  ///
  /// Every single time the download progress is updated a new ``SnackBar``containing the progress percentage is called.
  /// At the end of the download another ``SnackBar`` is called to inform the user about the path.
  /// A ``SnackBar`` is also used in case of error.
  Future<void> downloadUpdate() async {
    Future.delayed(
        const Duration(seconds: 2),
        () => _callSnackBar(
            message: 'New version $_newVersion detected', durationInSec: 3));
    Future.delayed(
        const Duration(seconds: 5),
        () => FileDownloader.downloadFile(
              url: _latestAPKLink,
              onProgress: (fileName, progress) => _callSnackBar(
                  message: 'Download progress: ${progress.round()}%',
                  durationInMil: 700),
              onDownloadCompleted: (path) => _callSnackBar(
                  message:
                      'Version $_newVersion downloaded at ${path.split('/')[4]}/${path.split('/').last}',
                  durationInSec: 5),
              onDownloadError: (errorMessage) => _callSnackBar(
                  message:
                      'Error while downloading $_newVersion: $errorMessage',
                  durationInSec: 3),
            ));
  }

  /// Function used to simplify the creation of a ``SnackBar``.
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
