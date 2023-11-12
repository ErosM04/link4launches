import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/installer_dialog_content.dart';
import 'package:link4launches/view/updater/updater_dialog_content.dart';

/// Automatically builds and shows different types of pre-fabricated ``[CustomDialog]`` using the ``[showGeneralDialog]`` method.
class DialogBuilder {
  final BuildContext context;

  const DialogBuilder(this.context);

  /// Uses ``[_invokeDialog]`` to show a [CustomDialog] that informs the user that a new version is available.
  ///
  /// #### Parameters
  /// - ``String [latestVersion]`` : the latest version available for the app.
  /// - ``DialogContent [content]`` : the content to insert below the title in the [CustomDialog].
  /// - ``Function [denyButtonAction]`` : the function to execute after the deny button is pressed.
  /// - ``Function [confirmButtonAction]`` : the function to execute after the confirm button is pressed.
  /// - ``bool [animate]`` : whether to animate the [CustomDialog], the paramter is used by ``[_invokeDialog]``.
  void invokeUpdateDialog({
    required String latestVersion,
    required UpdaterDialogContent content,
    required Function denyButtonAction,
    required Function confirmButtonAction,
    bool animate = true,
  }) =>
      _invokeDialog(
          animate: animate,
          dialog: CustomDialog(
            image: Image.asset(
              'assets/dialog/upgrade.png',
              scale: 9,
              color: const Color.fromARGB(255, 1, 202, 98),
            ),
            title: 'New version available',
            denyButtonAction: () => denyButtonAction(),
            confirmButtonAction: () => confirmButtonAction(),
            child: content,
          ));

  /// (Change) Uses ``[_invokeDialog]`` to show a [CustomDialog] that informs the user that a new version is available.
  ///
  /// #### Parameters
  /// - ``String [latestVersion]`` : the latest version available for the app.
  /// - ``DialogContent [content]`` : the content to insert below the title in the [CustomDialog].
  /// - ``Function [denyButtonAction]`` : the function to execute after the deny button is pressed.
  /// - ``Function [confirmButtonAction]`` : the function to execute after the confirm button is pressed.
  /// - ``bool [animate]`` : whether to animate the [CustomDialog], the paramter is used by ``[_invokeDialog]``.
  void invokePrereleaseUpdateDialog({
    required String latestVersion,
    required UpdaterDialogContent content,
    required Function denyButtonAction,
    required Function confirmButtonAction,
    bool animate = true,
  }) =>
      _invokeDialog(
          animate: animate,
          dialog: CustomDialog(
            image: Image.asset(
              'assets/dialog/alert.png',
              scale: 9,
              color: Colors.yellow,
            ),
            title: 'New prerelease version available',
            denyButtonAction: () => denyButtonAction(),
            confirmButtonAction: () => confirmButtonAction(),
            child: content,
          ));

  /// Uses ``[_invokeDialog]`` to show a [CustomDialog] that informs the user that something went wrong while installing the downloaded
  /// update file, so he/she will be redirected to the file manager to manually select it.
  ///
  /// #### Parameters
  /// - ``String [errorType]`` : the error message.
  /// - ``DialogContent [shortPath]`` : the short version of the path.
  /// - ``Function [denyButtonAction]`` : the function to execute after the deny button is pressed.
  /// - ``Function [confirmButtonAction]`` : the function to execute after the confirm button is pressed.
  /// - ``bool [animate]`` : whether to animate the [CustomDialog], the paramter is used by ``[_invokeDialog]``.
  void invokeInstallationErrorDialog({
    required String errorType,
    required String shortPath,
    required Function denyButtonAction,
    required Function confirmButtonAction,
    bool animate = true,
  }) =>
      _invokeDialog(
          animate: animate,
          dialog: CustomDialog(
            image: Image.asset(
              'assets/dialog/error.png',
              scale: 9,
              color: Colors.red,
            ),
            title: 'Error while installing the update',
            denyButtonAction: () => denyButtonAction(),
            confirmButtonAction: () => confirmButtonAction(),
            child: InstallerDialogContent(
              errorType: errorType,
              path: shortPath,
            ),
          ));

  void _invokeDialog({required CustomDialog dialog, required bool animate}) =>
      (animate) ? _invokeAnimatedDialog(dialog) : _invokeNormalDialog(dialog);

  /// Uses ``[showGeneralDialog]`` to show a [CustomDialog] (``[dialog]``) in the center of the screen.
  void _invokeNormalDialog(CustomDialog dialog) => showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
        transitionDuration: const Duration(milliseconds: 180),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            dialog,
      );

  /// Uses ``[showGeneralDialog]`` to show an animated [CustomDialog] (``[dialog]``) in the center of the screen.
  /// The animation consist in a slide transition from bottom to the center of the screen, meanwhile a fade transition occurs.
  void _invokeAnimatedDialog(CustomDialog dialog) => showGeneralDialog(
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
                  child: dialog,
                )),
      );
}
