import 'dart:io';
import 'package:flutter/material.dart';
import 'package:link4launches/logic/updater/updater.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/installer_dialog_content.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

/// This class is used in combination with [Updater] in order to install the downloaded apk file.
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
                .then(
              (result) => (result.type != ResultType.done)
                  ? _invokeDialog(
                      errorType: result.message,
                      shortPath: _getShortPath(path),
                    )
                  : null,
            ));
  }
  // storage/emulated/0/Download/link4launches.apk

  /// Fa le cose
  _invokeDialog({required String errorType, required String shortPath}) =>
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
                  opacity: Tween<double>(begin: 0.5, end: 1).animate(animation),
                  child: CustomDialog(
                    image: Image.asset(
                      'assets/dialog/error.png',
                      scale: 9,
                      color: Colors.red,
                    ),
                    title: 'Error while installing the upload',
                    denyButtonAction: () => _callSnackBar(message: ':('),
                    confirmButtonAction: () =>
                        _manuallySelectAndInstallUpdate(),
                    child: InstallerDialogContent(
                      errorType: errorType,
                      path: shortPath,
                    ),
                  ),
                )),
      );

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
          message: 'An error occurred while manually installing the update :(');
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
