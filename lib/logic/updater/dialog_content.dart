import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Class used to create the widgets to insert into the a [Dialog]. The content is the latest changes in the GitHub release.
class DialogContent extends StatelessWidget {
  /// The latest available version of the app.
  final String latestVersion;

  /// The string containg the body of the release.
  final String? changes;

  const DialogContent({
    super.key,
    required this.latestVersion,
    this.changes,
  });

  /// Reads the changes and extracts different types of data (than calls [buildContent]):
  /// - Features
  /// - Changes
  /// - Bug fixes
  /// Each element has it's own list of information (max 3 rows).
  /// Apart from these, it also creates a title and a link to the release.
  @override
  Widget build(BuildContext context) {
    String? title1;
    String? title2;
    String? title3;
    String text1 = '';
    String text2 = '';
    String text3 = '';
    String? link;
    String? linkText;

    if (changes != null && changes!.isNotEmpty) {
      String formattedChanges = changes!
          .replaceAll('\r', '')
          .replaceAll('\n', '')
          .replaceAll('``', '');

      if (formattedChanges.contains('###') &&
          (formattedChanges.contains('Features') ||
              formattedChanges.contains('Changes') ||
              formattedChanges.contains('Bug fixes'))) {
        List<String> arr = formattedChanges.split('###');
        title1 = '';
        title2 = '';
        title3 = '';

        for (var element in arr) {
          if (element.contains('Features') && element.contains('-')) {
            title1 = 'Features';
            // Uses sublist() to remove the fisr element which is the title ('Features')
            text1 = _composeRows(element.split('-').sublist(1));
          } else if (element.contains('Changes')) {
            title2 = 'Changes';
            text2 = _composeRows(element.split('-').sublist(1));
          } else if (element.contains('Bug fixes')) {
            title3 = 'Bug fixes';
            text3 += '- Various bug fixes';
          }
        }
        linkText = 'More info at:';
        link = 'link4launches';
      }
    }

    return buildContent(
      mainText: 'Download version $latestVersion?',
      subTitle1: title1,
      subTitle2: title2,
      subTitle3: title3,
      text1: text1,
      text2: text2,
      text3: text3,
      linkText: linkText,
      link: link,
    );
  }

  /// Takes a list of strings where each string is a description of a change and returns the complete list version.
  /// If the single row is too long (over 60), is clamped at the end and '...' are added.
  /// If there are more than 3 rows, only 4 rows are displayed and the 4th is will be '. . .'
  /// E.g.:
  /// ```
  /// rows = ['### Features', 'Added this cool thing', 'Now you can do that', 'Very long long long long string', 'bla bla bla bla']
  /// ```
  /// Result:
  /// ```
  /// """
  /// - AAdded this cool thing
  /// - Now you can do that
  /// - Very long long long lon...
  /// - . . .
  /// """
  /// ```
  ///
  /// #### Parameters
  /// - ``List<String> [rows]`` : the list of rows where each rows is a element of the list. Apart from the first element which is the title.
  ///
  /// #### Returns
  /// ``String`` : The complete text with every row starting with a '-'.
  String _composeRows(List<String> rows) {
    String str = '';

    for (var i = 0; i < ((rows.length <= 3) ? rows.length : 3); i++) {
      if (rows[i].trim().length <= 60) {
        str += '- ${rows[i].trim()}\n';
      } else {
        str += '- ${rows[i].trim().substring(0, 60).trim()}...\n';
      }
    }

    if (rows.length > 3) str += '- . . .';

    return str;
  }

  /// Graphically build the content for the [AlertDialog] using a Column and adding all the elemnts that are not null.
  /// To check if an element is null and not empty ``[_safeBuild]`` method is used.
  /// #### Parameters
  /// - ``String [mainText]`` : the text on the top ``'Vuoi scaricale la versione vx.x.x'``
  /// - ``String? [subTitle1]`` : the first subtitle
  /// - ``String? [subTitle2]`` : the second subtitle
  /// - ``String? [subTitle3]`` : the third subtitle
  /// - ``String? [text1]`` : the first text (under the 1st subtitle)
  /// - ``String? [text2]`` : the second text (under the 2nd subtitle)
  /// - ``String? [text3]`` : the third text (under the 3th subtitle)
  /// - ``String? [linkText]`` : the text befor the link
  /// - ``String? [link]`` : the link text
  ///
  /// #### Returns
  /// ``[Column]`` : the column with all the children.
  Column buildContent(
      {required String mainText,
      String? subTitle1,
      String? subTitle2,
      String? subTitle3,
      String? text1,
      String? text2,
      String? text3,
      String? linkText,
      String? link}) {
    // The column has to be constant in order to add the elements to the children list
    Column column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );

    // Version title
    column.children.add(_buildText(mainText, fontSize: 16.5));
    column.children.add(const SizedBox(height: 10));
    column.children.add(const Divider(
      height: 1,
      thickness: 2,
    ));
    column.children.add(const SizedBox(height: 10));

    // Functionalities
    column.children
        .add(_safeBuild(subTitle1, _buildText(subTitle1, isBold: true)));
    column.children.add(_safeBuild(subTitle1, const SizedBox(height: 4)));
    column.children.add(_safeBuild(text1, _buildText(text1)));
    column.children.add(_safeBuild(text1, const SizedBox(height: 10)));

    // Changes
    column.children
        .add(_safeBuild(subTitle2, _buildText(subTitle2, isBold: true)));
    column.children.add(_safeBuild(subTitle2, const SizedBox(height: 4)));
    column.children.add(_safeBuild(text2, _buildText(text2)));
    column.children.add(_safeBuild(text2, const SizedBox(height: 10)));

    // Bug fixies
    column.children
        .add(_safeBuild(subTitle3, _buildText(subTitle3, isBold: true)));
    column.children.add(_safeBuild(subTitle3, const SizedBox(height: 4)));
    column.children.add(_safeBuild(text3, _buildText(text3)));
    column.children.add(_safeBuild(text3, const SizedBox(height: 10)));
    column.children.add(const SizedBox(height: 7));

    // Link
    column.children.add(_safeBuild(
        link,
        Row(children: [
          _buildText(linkText),
          _safeBuild(linkText, const SizedBox(width: 5)),
          _buildLink(link),
        ])));

    column.children.add(const SizedBox(height: 10));
    column.children.add(const Divider(
      height: 1,
      thickness: 2,
    ));

    return column;
  }

  /// Allows to securely build ``[widget]`` only if the ``[str]`` is not null and not empty.
  Widget _safeBuild(String? str, Widget widget) =>
      (str != null && str.isNotEmpty) ? widget : Container();

  /// Returns a [Text] widget. If ``[text]`` is null, then is converted to an empty String ('').
  /// If ``[isLink]`` is true, then the text is blue and underlined. If ``[isBold]`` is true then the text is bold.
  /// The two can be combined together.
  Text _buildText(
    String? text, {
    bool isLink = false,
    bool isBold = false,
    double? fontSize,
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
                  fontWeight: (isBold) ? FontWeight.bold : null,
                  fontSize: fontSize),
            );

  /// Returns a clickable [Text] containg a link to the latest GitHub release. To build the [Text] uses ``[_buildText]``.
  Widget _buildLink(String? text) => GestureDetector(
        onTap: () => launchUrl(Uri.parse(
            'https://github.com/ErosM04/link4launches/releases/latest')),
        child: _buildText(text, isLink: true),
      );
}
