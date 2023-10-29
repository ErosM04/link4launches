import 'dart:io';
import 'package:flutter/material.dart';
import 'package:link4launches/logic/updater/updater.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/installer_dialog_content.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

/// This class is used by the [Updater] class in order to install the downloaded apk file.
class Installer {
  /// Context used to call both the [CustomSnackBar] and the [CustomDialog].
  final BuildContext context;

  const Installer(this.context);

  /// Installs the downloaded ``.apk`` file (which is the app update) located at ``[path]``.
  /// To open and execute the file ``[OpenFilex]`` is used.
  ///
  /// #### Parameters:
  /// - ``String [path]`` : the absolute path of the file (file included), e.g. ``storage/emulated/0/Download/link4launches.apk``
  Future<void> installUpdate(String path) async {
    OpenFilex.open(path).then(
      (result) => (result.type != ResultType.done)
          ? _invokeDialog(
              errorType: result.message,
              shortPath: _getShortPath(path),
            )
          : null,
    );
  }

  /// Uses ``[showGeneralDialog]`` to show a [CustomDialog] over the screen using both a fade and a slide animation.
  /// This [Dialog] informs the user that something went wrong while installing the downloaded update file, so he
  /// will be redirected to the file manager to manualy select it.
  ///
  /// #### Parameters
  /// - ``String [errorType]`` : the error message.
  /// - ``DialogContent [shortPath]`` : the short version of the path.
  void _invokeDialog({required String errorType, required String shortPath}) =>
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
                    title: 'Error while installing the update',
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

  /// Method used to manually install the apk by letting the user select it from the file manager, if [installUpdate] didn't work.
  /// To access the file uses [FilePicker].
  /// If something goes wrong while opening the file a [CustomSnackBar] with an error message is shown.
  Future<void> _manuallySelectAndInstallUpdate() async {
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

  /// Returns a short path format (only last 2 positions). Used for [CustomSnackBar] message.
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
