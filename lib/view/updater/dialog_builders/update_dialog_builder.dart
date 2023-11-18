import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_builders/dialog_builder.dart';
import 'package:link4launches/view/updater/dialog_contents/update_dialog_content.dart';

/// Extends ``[DialogBuilder]`` in order to create a [CustomDialog] suitable to infrom the user that an app ``update``
/// is available.
///
/// The dialog ``[content]`` should be a ``[UpdateDialogContent]`` widget.
class UpdateDialogBuilder extends DialogBuilder {
  const UpdateDialogBuilder({
    required super.context,
    required super.content,
    required super.denyButtonAction,
    required super.confirmButtonAction,
    super.animate,
  });

  /// Ovverrides the main [buildDialog] method in order to create an app update widget.
  /// The alert informs that a new version is available and uses a green upgrade image.
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
