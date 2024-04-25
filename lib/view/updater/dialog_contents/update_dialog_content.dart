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
  /// a split on '- '.
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
  ///(the "-" and the "- ..." are added in later methods)
  ///
  /// This method also extracts markdown links using ``[_extractLinks]``.
  @override
  Widget build(BuildContext context) {
    String? title1;
    String? title2;
    String? title3;
    List<String>? list1;
    List<String>? list2;
    List<String>? list3;
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

        // Every if inside the for-loop is executed only one time (in order)
        for (var element in arr) {
          if (element.contains('Features') && element.contains('-')) {
            title1 = 'Features';
            // Uses sublist() to remove the first element which is the title ('Features')
            // To split '- ' is used, beacuse '-' would also split on words like 'drop-down' or 'ahead-of-time'.
            list1 = element.split('- ').sublist(1);
          } else if (element.contains('Changes')) {
            title2 = 'Changes';
            list2 = element.split('- ').sublist(1);
          } else if (element.contains('Bug fixes')) {
            title3 = 'Bug fixes';
            list3 = ['Various bug fixes'];
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
      list1: list1,
      list2: list2,
      list3: list3,
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

  /// Graphically builds the content for the [CustomDialog] using a [Column] and adding all the elements that are not
  /// null or not empty. To check whether an element is null and not empty the ``[isSafe]`` method is used.
  ///
  /// #### Parameters
  /// - ``String [mainText]`` : the question text on the top ``'Downalod version vx.x.x?'``.
  /// - ``String? [subTitle1]`` : the first subtitle.
  /// - ``String? [subTitle2]`` : the second subtitle.
  /// - ``String? [subTitle3]`` : the third subtitle.
  /// - ``String? [list1]`` : the first list of stuff (under [subTitle1]).
  /// - ``String? [list2]`` : the second list of stuff (under [subTitle2]).
  /// - ``String? [list3]`` : the third list of stuff (under [subTitle3]).
  /// - ``String? [linkText]`` : the text befor the link.
  /// - ``String? [link]`` : the text to show before the link to the latest ``GitHub`` release.
  ///
  /// #### Returns
  /// ``[Column]`` : the column with all the children.
  Column buildContent(
      {required String mainText,
      String? subTitle1,
      String? subTitle2,
      String? subTitle3,
      List<String>? list1,
      List<String>? list2,
      List<String>? list3,
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
    buildAndAddSubtitle(subTitle1, children);
    buildAndAddList(list1, children);

    // Changes
    buildAndAddSubtitle(subTitle2, children);
    buildAndAddList(list2, children);

    // Bug fixies
    buildAndAddSubtitle(subTitle3, children);
    buildAndAddList(list3, children);
    children.add(const SizedBox(height: 7));

    // Link
    if (isSafe(link)) {
      children.add(Row(children: [
        buildCustomText(linkText),
        isSafe(linkText) ? const SizedBox(width: 5) : Container(),
        buildLink(
          text: link,
          url: 'https://github.com/ErosM04/link4launches/releases/latest',
        ),
      ]));
    }

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

  /// Iterates a ``[list]`` and add the first 3 elements to ``[children]`` using ``[buildListText]``. If the list has more than
  /// 3 elements the ". . ." elements is added. Also adds a [SizedBox].
  ///
  /// #### Parameters
  /// - ``List<String>? [list]`` : the list of elements.
  /// - ``List<Widget> [children]`` : the list of widget, that is going to contain the final list (plus the [SizedBox]).
  ///
  /// #### Returns
  /// ``[Column]`` : the column with all the children.
  void buildAndAddList(List<String>? list, List<Widget> children) {
    if (list != null) {
      for (int i = 0; (i < list.length && i < 3); i++) {
        children.add(buildListText(list[i]));
      }
      if (list.length > 3) {
        children.add(buildListText(". . ."));
      }
      children.add(const SizedBox(height: 10));
    }
  }

  /// Checks on [subTitle] with [isSafe] and than it's added to ``[children]`` using ``[buildCustomText]``. Also adds a [SizedBox].
  ///
  /// #### Parameters
  /// - ``String? [subTitle]`` : a text.
  /// - ``List<Widget> [children]`` : the list of widget, that is going to contain the final list (plus the [SizedBox]).
  ///
  /// #### Returns
  /// ``[Column]`` : the column with all the children.
  void buildAndAddSubtitle(String? subTitle, List<Widget> children) {
    if (isSafe(subTitle)) {
      children.add(buildCustomText(subTitle, isBold: true));
      children.add(const SizedBox(height: 4));
    }
  }
}
