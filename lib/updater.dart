import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:link4launches/snackbar.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class Updater {
  final String actualVersion = '1.3.0';
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/link4launches/releases/latest';
  final String _latestAPKLink =
      'https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk';
  final BuildContext context;
  String? _newVersion;

  Updater({required this.context});

  /// TRUE if there is an update to do, false if it's ok
  Future<bool> checkForUpdate() async {
    int statusCode = -1;

    try {
      var response = await http.get(Uri.parse(_latestReleaseLink));

      statusCode = response.statusCode;
      if (statusCode == 200) {
        var data = json.decode(response.body);
        _newVersion = data['tag_name'];
        return (actualVersion != data['tag_name']) ? true : false;
      }
    } on Exception catch (_) {}

    // If something went wrong shows the error using a snackbar
    callSnackBar(
        message: 'Error $statusCode: while looking for the latest version');
    return false;
  }

  /// Downloads the latest version of the app (apk) and save it in the Downloads folder
  Future<void> downloadUpdate() async {
    Future.delayed(
        const Duration(seconds: 2),
        () => callSnackBar(
            message: 'New version $_newVersion detected', durationInSec: 2));
    Future.delayed(
        const Duration(seconds: 4),
        () => FileDownloader.downloadFile(
              url: _latestAPKLink,
              onProgress: (fileName, progress) => callSnackBar(
                  message: 'Download progress: ${progress.round()}%',
                  durationInMil: 700),
              onDownloadCompleted: (path) => callSnackBar(
                  message:
                      'Version $_newVersion downloaded at ${path.split('/')[4]}/${path.split('/').last}',
                  durationInSec: 3),
              onDownloadError: (errorMessage) => callSnackBar(
                  message:
                      'Error while downloading $_newVersion: $errorMessage',
                  durationInSec: 3),
            ));
  }

  void callSnackBar(
          {required String message,
          int durationInSec = 2,
          int? durationInMil}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBarMessage(
              message: message,
              durationInSec: durationInSec,
              durationInMil: durationInMil)
          .build(context));
}
