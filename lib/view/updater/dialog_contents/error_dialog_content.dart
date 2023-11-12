import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/dialog_contents/dialog_content.dart';

/// [Widget] used to create the content to insert into a [Dialog]. The content is the latest changes in the GitHub release.
class ErrorDialogContent extends DialogContent {
  /// The error message (e.g. ``'File not found'``).
  final String errorType;

  /// The absolute path of the file (file included).
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
