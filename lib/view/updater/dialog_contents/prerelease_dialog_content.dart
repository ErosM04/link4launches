import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/custom_dialog.dart';
import 'package:link4launches/view/updater/dialog_builders/prerelease_dialog_builder.dart';
import 'package:link4launches/view/updater/dialog_contents/update_dialog_content.dart';

/// Overrides [UpdateDialogContent] to create a content to display inside a ``[PrereleaseDialogBuilder]``.
///
/// This widget creates a [Column] of widgets which:
/// - asks the user if he/she wants to update the app;
/// - infroms the user that he is about to install an unstable version;
/// - informs the user about what has changed (Features, Changes and Bug fixes);
/// - offers a link to redirect the user to the ``GitHub`` latest release page containg all the detailed release infromations.
///
/// This widget is a extended version of [UpdateDialogContent] which only adds a warning yellow text.
class PrereleaseDialogContent extends UpdateDialogContent {
  const PrereleaseDialogContent(
      {super.key, required super.latestVersion, super.changes});

  /// Graphically builds the content for the [CustomDialog] using a [Column] and adding all the elements that are not
  /// null or not empty. To check whether an element is null and not empty the ``[isSafe]`` method is used.
  /// Also adds a warning yellow text that informs the user that this is an unstable version.
  ///
  /// #### Parameters
  /// - ``String [mainText]`` : the question text on the top ``'Downalod version vx.x.x?'``.
  /// - ``String? [subTitle1]`` : the first subtitle.
  /// - ``String? [subTitle2]`` : the second subtitle.
  /// - ``String? [subTitle3]`` : the third subtitle.
  /// - ``String? [list1]`` : the first list of elements (under [subTitle1]).
  /// - ``String? [list2]`` : the second list of elements (under [subTitle2]).
  /// - ``String? [list3]`` : the third list of elements (under [subTitle3]).
  /// - ``String? [linkText]`` : the text befor the link.
  /// - ``String? [link]`` : the text to show before the link to the latest ``GitHub``.
  ///
  /// #### Returns
  /// ``[Column]`` : the column with all the children.
  @override
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

    // Informs the user that he/she is about to install a prerelease version
    children.add(buildCustomText(
      'Pay attention as this is a prerelease version and may be unstable!',
      color: Colors.yellow,
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
}
