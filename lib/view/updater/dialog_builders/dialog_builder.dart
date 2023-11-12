import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_contents/dialog_content.dart';

/// Automatically builds and shows different types of pre-fabricated ``[CustomDialog]`` using the ``[showGeneralDialog]`` method.
class DialogBuilder {
  final BuildContext context;
  final DialogContent content;
  final Function denyButtonAction;
  final Function confirmButtonAction;
  final bool animate;

  const DialogBuilder({
    required this.context,
    required this.content,
    required this.denyButtonAction,
    required this.confirmButtonAction,
    this.animate = true,
  });

  void invokeDialog() => _invokeDialog(dialog: buildDialog());

  CustomDialog buildDialog() => CustomDialog(
        image: Image.asset('assets/dialog/upgrade.png'),
        title: 'Title',
        denyButtonAction: denyButtonAction,
        confirmButtonAction: confirmButtonAction,
        child: Container(),
      );

  void _invokeDialog({required CustomDialog dialog}) =>
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
