import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_builders/dialog_builder.dart';
import 'package:link4launches/view/updater/dialog_contents/prerelease_dialog_content.dart';

/// Extends ``[DialogBuilder]`` in order to create a [CustomDialog] suitable to infrom the user that the app can be
/// updated to a ``prerelease`` version. Despite giving access to the latest changes the prerelease version also could
/// come with some bugs.
///
/// The dialog ``[content]`` should be a ``[PrereleaseDialogContent]`` widget.
class PrereleaseDialogBuilder extends DialogBuilder {
  const PrereleaseDialogBuilder({
    required super.context,
    required super.content,
    required super.denyButtonAction,
    required super.confirmButtonAction,
    super.animate,
  });

  /// Ovverrides the main [buildDialog] method in order to create an app prerelease update widget.
  /// The alert informs that a new unstable version is available and uses a yellow alert (!) image.
  @override
  CustomDialog buildDialog() => CustomDialog(
        image: Image.asset(
          'assets/dialog/alert.png',
          scale: 9,
          color: Colors.yellow,
        ),
        title: 'New prerelease version available',
        denyButtonAction: denyButtonAction,
        confirmButtonAction: confirmButtonAction,
        child: content,
      );
}
