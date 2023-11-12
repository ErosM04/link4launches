import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_builders/dialog_builder.dart';

class ErrorDialogBuilder extends DialogBuilder {
  const ErrorDialogBuilder({
    required super.context,
    required super.content,
    required super.denyButtonAction,
    required super.confirmButtonAction,
    super.animate,
  });

  /// Uses ``[_invokeDialog]`` to show a [CustomDialog] that informs the user that something went wrong while installing the downloaded
  /// update file, so he/she will be redirected to the file manager to manually select it.
  ///
  /// #### Parameters
  /// - ``String [errorType]`` : the error message.
  /// - ``DialogContent [shortPath]`` : the short version of the path.
  /// - ``Function [denyButtonAction]`` : the function to execute after the deny button is pressed.
  /// - ``Function [confirmButtonAction]`` : the function to execute after the confirm button is pressed.
  /// - ``bool [animate]`` : whether to animate the [CustomDialog], the paramter is used by ``[_invokeDialog]``.
  @override
  CustomDialog buildDialog() => CustomDialog(
        image: Image.asset(
          'assets/dialog/error.png',
          scale: 9,
          color: Colors.red,
        ),
        title: 'Error while installing the update',
        denyButtonAction: denyButtonAction,
        confirmButtonAction: confirmButtonAction,
        child: content,
      );
}
