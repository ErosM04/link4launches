import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Creates a [Column] containing differents widgets. Those widgets will be the content displayed inside the ``[CustomDialog]``.
/// This widget only returns an empty [Column] as it's meant to be extended, so it implements only some useful methods.
class DialogContent extends StatelessWidget {
  const DialogContent({super.key});

  @override
  Widget build(BuildContext context) => const Column();

  /// Checks on the ``[str]`` to verify that it isn't neither null nor false.
  /// #### Returns
  /// ``bool`` : true if the string isn't null and empty, false otherwise.
  bool isSafe(String? str) => (str != null && str.isNotEmpty);

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

  /// Allows to create a customizable ``[Text]`` widget that can be used as a list elements since before the
  /// text contained in ``[text]`` there is a ``"-"`` character to mark this is a list element.
  /// E.g.
  /// ```
  /// "- This is the text..."
  /// ```
  /// The [SizedBox] is used to prevent the text from overlowing horizontally.
  ///
  /// #### Parameters:
  /// - ``String? [text]`` : the literal content of the text. if it's null, then a empty [Text] is returned.
  /// - ``double? [fontSize]`` : the font size of the text.
  /// - ``Color? [color]`` : the color of the text.
  Widget buildListText(
    String? text, {
    double? fontSize,
    Color? color,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("-"),
          const SizedBox(width: 3),
          Expanded(
            // width: 230,
            child: Text(
              (text == null) ? '' : text.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
