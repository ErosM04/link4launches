import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:link4launches/snackbar.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:link4launches/updater/dialog_content.dart';
import 'package:permission_handler/permission_handler.dart';

class Updater {
  final String actualVersion = '1.5.0';
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/link4launches/releases/latest';
  final String _latestAPKLink =
      'https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk';
  final BuildContext context;

  Updater({required this.context});

  // If the latest version is different from the actual then asks for update consent.
  /// if the version is ahead then returns ``true``, otherwise display an error ``SnackBar`` and returns ``false``.
  Future updateToNewVersion() async {
    String latestVersion = '1.6.1';
    //     (await _getLatestVersionData('tag_name')).replaceAll('v', '');
    // if (latestVersion != actualVersion && latestVersion.isNotEmpty) {
    _callDialog(
      latestVersion: latestVersion,
      content: _buildDialogContent(
          latestVersion: latestVersion,
          changes: await _getLatestVersionJson('body')),
    );
    // }
  }

  /// Performs a request to the Github API to obtain a json about the latest release.
  /// ``key`` is the key used to get the corressponding value from the json.
  Future<String> _getLatestVersionJson(String key) async {
    int statusCode = -1;

    try {
      var response = await http.get(Uri.parse(_latestReleaseLink));

      statusCode = response.statusCode;
      if (statusCode == 200) {
        var data = json.decode(response.body);
        return data[key].toString();
      }
    } on Exception catch (_) {
      _callSnackBar(
          message: 'Error $statusCode: while looking for the latest version');
    }

    return '';
  }

  DialogContent _buildDialogContent(
      {required String latestVersion, String? changes}) {
    String? title;
    String text = '';
    String? link;

    if (changes != null && changes.isNotEmpty) {
      changes = changes
          .replaceAll('\r', '')
          .replaceAll('\n', '')
          .replaceAll('``', '');

      if (changes.contains('###') &&
          (changes.contains('Features') ||
              changes.contains('Changes') ||
              changes.contains('Bug fixes'))) {
        List<String> arr = changes.split('###');
        title = '';

        for (var element in arr) {
          if (element.contains('Features') && element.contains('-')) {
            title = 'Features';
            List<String> rows = element.split('-');

            for (var i = 1; i < rows.length; i++) {
              if (rows[i].trim().length <= 55) {
                text += '- ${rows[i].trim()}\n';
              } else {
                text += '- ${rows[i].trim().substring(0, 55)}...\n';
              }
            }
          } else if (element.contains('Changes')) {
            if (title!.isEmpty) {
              title = 'Changes';
            }
            text += '- Various changes';
          } else if (element.contains('Bug fixes')) {
            if (title!.isEmpty) {
              title = 'Bug fixes';
            }
            text += '- Various bug fixies';
          }
        }
      }
    }

    return DialogContent(
      mainText: 'Download version $latestVersion?',
      subTitle: title,
      text: text,
      link: link,
    );
  }

  void _callDialog({
    required String latestVersion,
    required DialogContent content,
  }) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: const Text('New version available'),
                content: content,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      _callSnackBar(message: ':(');
                      Navigator.pop(context);
                    },
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _downloadUpdate(latestVersion);
                      Navigator.pop(context);
                    },
                    child: const Text('Yes'),
                  )
                ],
              ));

  /// After 2 seconds shows a ``SnackBar`` to inform the user that the new version has been detected.
  /// Two seconds later downloads the latest version of the app (link4launches.apk) and save it in the Downloads folder.
  ///
  /// Every single time the download progress is updated a new ``SnackBar``containing the progress percentage is called.
  /// At the end of the download another ``SnackBar`` is called to inform the user about the path.
  /// A ``SnackBar`` is also used in case of error.
  Future<void> _downloadUpdate(String latestVersion) async {
    // Starts the download
    // this package use some deprecated shit, but who am I to judge?, this works so it's fine to me
    FileDownloader.downloadFile(
      url: _latestAPKLink.trim(),
      onProgress: (fileName, progress) => _callSnackBar(
          message: 'Download progress: ${progress.round()}%',
          durationInMil: 700),
      onDownloadCompleted: (path) => _callSnackBar(
          message:
              'Version $latestVersion downloaded at ${path.split('/')[4]}/${path.split('/').last}',
          durationInSec: 5),
      onDownloadError: (errorMessage) => _callSnackBar(
          message: 'Error while downloading $latestVersion: $errorMessage',
          durationInSec: 3),
    );
  }

  /// Function used to simplify the invocation and the creation of a ``SnackBar``.
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
