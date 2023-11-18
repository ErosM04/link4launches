import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_contents/dialog_content.dart';

/// Builds a basic ``[CustomDialog]`` using the given parameters and allows to invoke it (display it) using the ``[invokeDialog]`` method.
/// It also offers the possibility to animate the widget with a bottom-to-center [SlideTransition] and a [FadeTransition].
class DialogBuilder {
  /// The app context used to display the [CustomDialog].
  final BuildContext context;

  /// The widgets to insert in the [CustomDialog].
  /// Those are placed between the title (on top) and the action buttons (on bottom).
  final DialogContent content;

  /// The action to perform when the 'deny' button is pressed.
  final Function denyButtonAction;

  /// The action to perform when the 'confirm' button is pressed.
  final Function confirmButtonAction;

  /// Whether to animate the [CustomDialog].
  final bool animate;

  const DialogBuilder({
    required this.context,
    required this.content,
    required this.denyButtonAction,
    required this.confirmButtonAction,
    this.animate = true,
  });

  /// Builds the ``[CustomDialog]`` using ``[buildDialog]`` and displays it on top of the screen.
  void invokeDialog() => _invokeDialog(dialog: buildDialog());

  /// Uses the class variables to build a ``[CustomDialog]``.
  /// This is a basic implementation of a plain [CustomDialog] as it's meant to be ``overrided``.
  CustomDialog buildDialog() => CustomDialog(
        image: Image.asset('assets/dialog/upgrade.png'),
        title: 'Title',
        denyButtonAction: denyButtonAction,
        confirmButtonAction: confirmButtonAction,
        child: Container(),
      );

  /// Takes a [CustomDialog] to display and than decides whether to display it with an animation or not, by reading ``[animate]``.
  /// If the dialog has to be animated ``[_invokeAnimatedDialog]`` is used, otherwise ``[_invokeNormalDialog]`` is used.
  void _invokeDialog({required CustomDialog dialog}) =>
      (animate) ? _invokeAnimatedDialog(dialog) : _invokeNormalDialog(dialog);

  /// Uses ``[showGeneralDialog]`` to show a [CustomDialog] (``[dialog]``), without any animation, in the center of the screen.
  void _invokeNormalDialog(CustomDialog dialog) => showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
        transitionDuration: const Duration(milliseconds: 180),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            dialog,
      );

  /// Uses ``[showGeneralDialog]`` to show an animated [CustomDialog] (``[dialog]``) in the center of the screen.
  /// The animation consist in a bottom-to-center ``[SlideTransition]`` and a ``[FadeTransition]``.
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
