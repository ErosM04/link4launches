import 'package:flutter/material.dart';

/// [Widget] used to create the content to insert into a [Dialog]. The content is the latest changes in the GitHub release.
class InstallerDialogContent extends StatelessWidget {
  /// The error message (e.g. ``'File not found'``).
  final String errorType;

  /// The absolute path of the file (file included).
  final String path;

  const InstallerDialogContent({
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
          buildCustomText(text: errorType, color: Colors.red),
          const SizedBox(height: 10),
          const Text(
              'Now you will be redirected to the file manager in order to select the update file, located at:'),
          const SizedBox(height: 5),
          buildCustomText(text: path, color: Colors.blue),
        ],
      );

  /// Builds a custom [Text] widget with a custom color.
  ///
  /// #### Parametrs:
  /// - ``String [text]`` : the string to use as text.
  /// - ``Color? [color]`` : the color of the text.
  Text buildCustomText({required String text, Color? color}) => Text(
        text,
        style: TextStyle(color: color),
      );
}
