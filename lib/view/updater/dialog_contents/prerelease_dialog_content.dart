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
  /// null or not empty. To check whether an element is null and not empty the ``[safeBuild]`` method is used.
  /// Also adds a warning yellow text that informs the user that this is an unstable version.
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
  @override
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

    // Informs the user that he/she is about to install a prerelease version
    children.add(buildCustomText(
      'Pay attention as this is a prerelease version and may be unstable!',
      color: Colors.yellow,
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
