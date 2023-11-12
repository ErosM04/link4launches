import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Creates a [Column] containing differents widgets. Those widgets will be the content displayed inside the [CustomDialog].
class DialogContent extends StatelessWidget {
  const DialogContent({super.key});

  @override
  Widget build(BuildContext context) => const Column();

  /// Allows to securely build ``[widget]`` only if the ``[str]`` is not null and not empty.
  Widget safeBuild(String? str, Widget widget) =>
      (str != null && str.isNotEmpty) ? widget : Container();

  /// Returns a [Text] widget. If ``[text]`` is null, then is converted to an empty String ('').
  /// If ``[isLink]`` is true, then the text is blue and underlined. If ``[isBold]`` is true then the text is bold.
  /// The two can be combined together.
  Text buildCustomText(
    String? text, {
    bool isLink = false,
    bool isBold = false,
    double? fontSize,
    Color? color,
  }) =>
      (isLink)
          ? Text((text == null) ? '' : text.trim(),
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
                fontWeight: (isBold) ? FontWeight.bold : null,
                fontSize: fontSize,
              ))
          : Text(
              (text == null) ? '' : text.trim(),
              style: TextStyle(
                  color: color,
                  fontWeight: (isBold) ? FontWeight.bold : null,
                  fontSize: fontSize),
            );

  /// Returns a clickable [Text] containg a link to the latest GitHub release. To build the [Text] uses ``[buildCustomText]``.
  Widget buildLink({required String? text, required String url}) =>
      GestureDetector(
        onTap: () => launchUrl(Uri.parse(url)),
        child: buildCustomText(text, isLink: true),
      );
}
