import 'dart:io';
import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

class Installer {
  final BuildContext context;

  const Installer(this.context);

  /// Install the downloaded apk
  Future installUpdate(
      {required String latestVersion, required String path}) async {
    // Informs the user that the download ended and where he can find the file.
    _callSnackBar(
      message: 'Version $latestVersion downloaded at ${_getShortPath(path)}',
      durationInSec: 5,
    );

    // Removes the '/' at the start of the path, otherwise it would be wrong
    Future.delayed(
        const Duration(seconds: 5),
        () => OpenFilex.open((path.startsWith('/')) ? path.substring(1) : path)
                .then((result) {
              if (result.type != ResultType.done) {
                _callSnackBar(
                  message:
                      'Error while installing the upload, code: ${result.message}',
                  durationInSec: 4,
                );
                _callSnackBar(
                  message:
                      'To solve manually install apk file at: ${_getShortPath(path)}',
                  durationInSec: 6,
                );
                Future.delayed(
                  const Duration(seconds: 10),
                  () => _manuallySelectAndInstallUpdate(),
                );
              }
            }));
  }
  // storage/emulated/0/Download/link4launches.apk

  /// Method used to manually install the apk by picking it, if [installUpdate] didn't work. Uses [FilePicker].
  Future _manuallySelectAndInstallUpdate() async {
    try {
      FilePickerResult? pickResult = await FilePicker.platform.pickFiles();

      if (pickResult != null && pickResult.files.single.path != null) {
        File file = File(pickResult.files.single.path!);
        var installResult = await OpenFilex.open(file.path);
        if (installResult.type != ResultType.done) {
          throw Exception();
        }
      } else {
        throw Exception();
      }
    } catch (e) {
      _callSnackBar(
          message: 'Error occurred while manually installing the file :(');
    }
  }

  /// Returns a short path form (only last 2) for [CustomSnackBar] message.
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
