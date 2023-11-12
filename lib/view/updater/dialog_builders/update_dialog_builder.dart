import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_builders/dialog_builder.dart';

class UpdateDialogBuilder extends DialogBuilder {
  const UpdateDialogBuilder({
    required super.context,
    required super.content,
    required super.denyButtonAction,
    required super.confirmButtonAction,
    super.animate,
  });

  /// Uses ``[_invokeDialog]`` to show a [CustomDialog] that informs the user that a new version is available.
  ///
  /// #### Parameters
  /// - ``String [latestVersion]`` : the latest version available for the app.
  /// - ``DialogContent [content]`` : the content to insert below the title in the [CustomDialog].
  /// - ``Function [denyButtonAction]`` : the function to execute after the deny button is pressed.
  /// - ``Function [confirmButtonAction]`` : the function to execute after the confirm button is pressed.
  /// - ``bool [animate]`` : whether to animate the [CustomDialog], the paramter is used by ``[_invokeDialog]``.
  @override
  CustomDialog buildDialog() => CustomDialog(
        image: Image.asset(
          'assets/dialog/upgrade.png',
          scale: 9,
          color: const Color.fromARGB(255, 1, 202, 98),
        ),
        title: 'New version available',
        denyButtonAction: denyButtonAction,
        confirmButtonAction: confirmButtonAction,
        child: content,
      );
}
