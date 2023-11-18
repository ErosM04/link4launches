import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Creates a [Column] containing differents widgets. Those widgets will be the content displayed inside the ``[CustomDialog]``.
/// This widget only returns an empty [Column] as it's meant to be extended, so it implements only some useful methods.
class DialogContent extends StatelessWidget {
  const DialogContent({super.key});

  @override
  Widget build(BuildContext context) => const Column();

  /// Allows to securely build a ``[widget]`` only if ``[str]`` is not null and not empty.
  /// Otherwise returns an empty [Container].
  Widget safeBuild(String? str, Widget widget) =>
      (str != null && str.isNotEmpty) ? widget : Container();

  /// Allows to create a customizable ``[Text]`` widget.
  ///
  /// #### Parameters:
  /// - ``String? [text]`` : the literal content of the text. if it's null, then a empty [Text] is returned.
  /// - ``bool [isLink]`` : if it's true the text is blue and underlined.
  /// - ``bool [isBold]`` : if it's true the text has a weight set to bold.
  /// - ``double? [fontSize]`` : the font size of the text.
  /// - ``Color? [color]`` : the color of the text.
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

  /// Returns a clickable ``[Text]`` containg a blue and underlined text that acts as a link to the ``[url]``.
  /// In order to build the custom [Text], ``[buildCustomText]`` is used.
  ///
  /// #### Parameters:
  /// - ``String? [text]`` : the literal content of the text. if it's null, then a empty [Text] is returned.
  /// - ``String [url]`` : the link to open when the [Text] is cliked (e.g. 'https://scemo-chi-legge.com').
  Widget buildLink({required String? text, required String url}) =>
      GestureDetector(
        onTap: () => launchUrl(Uri.parse(url)),
        child: buildCustomText(text, isLink: true),
      );
}
