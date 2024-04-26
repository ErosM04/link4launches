// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:link4launches/logic/updater/installer.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_builders/prerelease_dialog_builder.dart';
import 'package:link4launches/view/updater/dialog_builders/update_dialog_builder.dart';
import 'package:link4launches/view/updater/dialog_contents/prerelease_dialog_content.dart';
import 'package:link4launches/view/updater/dialog_contents/update_dialog_content.dart';

/// Class used to update the app to the latest version. It works by looking for a new release in the ``GitHub`` repository
/// (using a GitHub API) and then downloads the new version in the ``Download`` folder, after the user gave the consent (with a [CustomDialog]).
///
/// Then uses the ``[Installer]`` object to install the downloaded ``.apk`` file.
class Updater {
  /// The actual version of the app (``!!! it has to be change every release !!!``).
  final String actualVersion = '1.0.0';

  /// Link to the GitHub API used to get the json containg the latest release data.
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/link4launches/releases/latest';

  /// Link to the apk file of the latest app version in the latest GitHub release.
  final String _latestApkLink =
      'https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk';

  /// Context used to call both the ``[CustomSnackBar]`` and the ``[CustomDialog]``.
  final BuildContext context;

  const Updater(this.context);

  /// Uses ``[_getLatestVersionData]`` to get a [Map] containing the latest version id, the latest changes...
  ///
  /// If the latest version is different from the actual version and the release isn't a draft, then asks for update consent
  /// to the user by using either ``[UpdateDialogBuilder]`` or ``[PrereleaseDialogBuilder]`` to invoke a [CustomDialog].
  /// If the user gives the consent, the download starts by calling the method ``[_downloadUpdate]``.
  Future updateToNewVersion() async {
    var data = await _getLatestVersionData();

    if (data.isNotEmpty &&
        (data['version'].toString() != actualVersion && !data['draft'])) {
      if (data['prerelease']) {
        // It's a prerelease update
        PrereleaseDialogBuilder(
          context: context,
          content: PrereleaseDialogContent(
            latestVersion: data['version'].toString(),
            changes: data['description'].toString(),
          ),
          denyButtonAction: () => _callSnackBar(message: ':('),
          confirmButtonAction: () =>
              _downloadUpdate(data['version'].toString()),
        ).invokeDialog();
      } else {
        // It's a normal update
        UpdateDialogBuilder(
          context: context,
          content: UpdateDialogContent(
            latestVersion: data['version'].toString(),
            changes: data['description'].toString(),
          ),
          denyButtonAction: () => _callSnackBar(message: ':('),
          confirmButtonAction: () =>
              _downloadUpdate(data['version'].toString()),
        ).invokeDialog();
      }
    }
  }

  /// Performs a request to the Github API to obtain a json within info about the latest release data, the link used is
  /// ``[_latestReleaseLink]``.
  /// If anything goes wrong an [Exception] is thrown and an error message [CustomSnackBar] is showed.
  ///
  /// #### Returns
  /// ``Future<Map<String, String>>`` : a map containing info about the latest GitHub release of the app's repository.
  /// Returns an empty map if any error occurs.
  ///
  /// E.g.:
  /// ```
  /// {
  ///   'version' : '1.0.0',
  ///   'description' : '...',
  ///   'draft' : false,
  ///   'prerelease' : false,
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
  /// and saved in the ``Downloads`` folder.
  ///
  /// Then the file is installed using the ``[Installer]`` object.
  /// Otherwise if the download failed, a [CustomSnackBar] with an error message is shown.
  /// To show the [CustomSnackBar] the ``[_callSnackBar]`` method is used.
  ///
  /// In order for the ``[Installer]`` to be able to properly open the path, if this starts with the ``'/'`` character, it is removed.
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

  /// Returns a short path format (only last 2 positions) of ``[path]``. Used for [CustomSnackBar] message.
  ///
  /// E.g.: ``storage/emulated/0/Download/link4launches.apk`` --> ``Download/link4launches.apk``
  String _getShortPath(String path, {String splitCarachter = '/'}) =>
      '${path.split(splitCarachter)[path.split(splitCarachter).length - 2]}/${path.split(splitCarachter).last}';

  /// Function used to simplify the invocation of the ``[CustomSnackBar]``.
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
