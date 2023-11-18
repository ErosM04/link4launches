import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_builders/update_dialog_builder.dart';
import 'package:link4launches/view/updater/dialog_contents/dialog_content.dart';

/// Overrides [DialogContent] to create a content to display inside an ``[UpdateDialogBuilder]``.
///
/// This widget creates a [Column] of widgets which:
/// - asks the user if he/she wants to update the app;
/// - informs the user about what has changed (Features, Changes and Bug fixes);
/// - offers a link to redirect the user to the ``GitHub`` latest release page containg all the detailed release infromations.
class UpdateDialogContent extends DialogContent {
  /// The latest available version of the app.
  final String latestVersion;

  /// The string containg the body of the release.
  final String? changes;

  const UpdateDialogContent({
    super.key,
    required this.latestVersion,
    this.changes,
  });

  /// Reads the changes and extracts various type of data, than creates the widget by calling ``[buildContent]``:
  /// - Main text: the question to the user "Download version x.x.x?";
  /// - The changes:
  ///   - Features: new functionalities, such as the ability to zoom an image;
  ///   - Changes: modifies some things that already exited, usually improving the behavior or the code structure;
  ///   - Bug fixes: code bugs adjusted or bad code that was modified. For this only "Various bug fixes" is shown.
  /// - In the end adds a link to the latest release.
  ///
  /// Except for 'Bug fixies', each of the 3 changes has it's own list of information (max 3 rows), obtained with
  /// ``[_composeRows]``. If the amount of information is higher than 3, some dots ('...') are showed.
  /// If the entry of the list is too long, it's shortened and '...' are added at the end.
  ///
  /// E.g.:
  /// ```
  /// "Download version x.x.x?"
  /// ------------------------------------------------
  /// "Features
  /// - Changed package name (app id) to ErosM04.link4launches
  /// - Lunch page images are now zoomable
  /// - Divided readme info in 2 files, README.md and MORE_INFO.md
  /// - ...
  ///
  /// Changes
  /// - Added date to launch tile in home page
  /// - Modified code and style of Updater
  /// - Created a file for the theme
  /// - ...
  ///
  /// Bug fixes
  /// - Various bug fixes
  ///
  /// More info at: link4launches"
  /// ------------------------------------------------
  /// ```
  ///
  /// This method also extracts markdown links using ``[_extractLinks]``.
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
      formattedChanges = _extractLinks(formattedChanges);

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
            // Uses sublist() to remove the first element which is the title ('Features')
            // To split '- ' is used, beacuse '-' would also include words like 'drop-down' or 'ahead-of-time'.
            text1 = _composeRows(element.split('- ').sublist(1));
          } else if (element.contains('Changes')) {
            title2 = 'Changes';
            text2 = _composeRows(element.split('- ').sublist(1));
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

  /// Removes GitHub links (``[Name](link)``) parentesis and name, leaving only the link.
  ///
  /// E.g. ``[Site](https://hhh.culo)`` --> ``https://hhh.culo``
  ///
  /// #### Parameters
  /// - ``String [changes]`` : the string containing the text with the GitHub links format.
  ///
  /// #### Returns
  /// ``String`` : the input text with the normal links.
  ///
  /// ``ATTENTION!!`` This code breakes the ``Updater`` if there are ``[`` and ``]`` characters which are not used for links,
  /// but for other pourposes.
  String _extractLinks(String changes) {
    while (true) {
      int startSquare = changes.indexOf('[');
      int endSquare = changes.indexOf(']');

      if (startSquare == -1) {
        break;
      } else if ((changes[endSquare + 1] == '(') &&
          changes.substring(startSquare + 1).contains(')')) {
        int startRound = endSquare + 1;
        int endRound = changes.substring(startRound).indexOf(')') + startRound;
        changes =
            '${changes.substring(0, startSquare)}${changes.substring((startRound + 1), endRound)}${changes.substring((endRound + 1))}';
      }
    }

    return changes;
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
  /// - Added this cool thing
  /// - Now you can do that
  /// - Very long long long lon...
  /// - . . .
  /// """
  /// ```
  /// Apart from the example the entryes of the list can also be 2 rows long.
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

  /// Graphically builds the content for the [CustomDialog] using a [Column] and adding all the elements that are not
  /// null or not empty. To check whether an element is null and not empty the ``[safeBuild]`` method is used.
  ///
  /// #### Parameters
  /// - ``String [mainText]`` : the question text on the top ``'Downalod version vx.x.x?'``.
  /// - ``String? [subTitle1]`` : the first subtitle.
  /// - ``String? [subTitle2]`` : the second subtitle.
  /// - ``String? [subTitle3]`` : the third subtitle.
  /// - ``String? [text1]`` : the first text (under [subTitle1]).
  /// - ``String? [text2]`` : the second text (under [subTitle2]).
  /// - ``String? [text3]`` : the third text (under [subTitle3]).
  /// - ``String? [linkText]`` : the text befor the link.
  /// - ``String? [link]`` : the text to show before the link to the latest ``GitHub``.
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
    List<Widget> children = [];

    // Version title
    children.add(buildCustomText(mainText, fontSize: 16.5));
    children.add(const SizedBox(height: 10));
    children.add(const Divider(
      height: 1,
      thickness: 2,
    ));
    children.add(const SizedBox(height: 10));

    // Functionalities
    children
        .add(safeBuild(subTitle1, buildCustomText(subTitle1, isBold: true)));
    children.add(safeBuild(subTitle1, const SizedBox(height: 4)));
    children.add(safeBuild(text1, buildCustomText(text1)));
    children.add(safeBuild(text1, const SizedBox(height: 10)));

    // Changes
    children
        .add(safeBuild(subTitle2, buildCustomText(subTitle2, isBold: true)));
    children.add(safeBuild(subTitle2, const SizedBox(height: 4)));
    children.add(safeBuild(text2, buildCustomText(text2)));
    children.add(safeBuild(text2, const SizedBox(height: 10)));

    // Bug fixies
    children
        .add(safeBuild(subTitle3, buildCustomText(subTitle3, isBold: true)));
    children.add(safeBuild(subTitle3, const SizedBox(height: 4)));
    children.add(safeBuild(text3, buildCustomText(text3)));
    children.add(safeBuild(text3, const SizedBox(height: 10)));
    children.add(const SizedBox(height: 7));

    // Link
    children.add(safeBuild(
        link,
        Row(children: [
          buildCustomText(linkText),
          safeBuild(linkText, const SizedBox(width: 5)),
          buildLink(
            text: link,
            url: 'https://github.com/ErosM04/link4launches/releases/latest',
          ),
        ])));

    children.add(const SizedBox(height: 10));
    children.add(const Divider(
      height: 1,
      thickness: 2,
    ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
