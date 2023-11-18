import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/dialog_contents/dialog_content.dart';

/// Overrides [DialogContent] to create a content to display inside an ``[ErrorDialogContent]``.
///
/// This widget creates a [Column] of widgets which:
/// - asks the user if he/she wants to manually install the update;
/// - informs the user about the error that occurred while installing the update file (e.g. ``'File not found'``);
/// - informs the user that he/she is about to be redirected to the file manager and that he/she has to pick a file
/// located at a specific path;
class ErrorDialogContent extends DialogContent {
  /// The error message (e.g. ``'File not found'``).
  final String errorType;

  /// The path of the file (filename and extension included).
  final String path;

  const ErrorDialogContent({
    super.key,
    required this.errorType,
    required this.path,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Do you want to manually install the update apk file?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 15),
          const Text(
              'While trying to install the update you just downloaded an error occurred:'),
          const SizedBox(height: 3),
          safeBuild(errorType, buildCustomText(errorType, color: Colors.red)),
          const SizedBox(height: 10),
          const Text(
              'Now you will be redirected to the file manager in order to select the update file, located at:'),
          const SizedBox(height: 5),
          safeBuild(path, buildCustomText(path, color: Colors.blue)),
        ],
      );
}
