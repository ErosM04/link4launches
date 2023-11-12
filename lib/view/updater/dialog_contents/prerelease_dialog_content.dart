import 'package:flutter/material.dart';
import 'package:link4launches/view/updater/dialog_contents/update_dialog_content.dart';

/// [Widget] used to create the content to insert into a [Dialog]. The content is the latest changes in the GitHub release.
class PrereleaseDialogContent extends UpdateDialogContent {
  const PrereleaseDialogContent(
      {super.key, required super.latestVersion, super.changes});

  /// Graphically build the content for the [AlertDialog] using a Column and adding all the elemnts that are not null.
  /// To check if an element is null and not empty ``[safeBuild]`` method is used.
  ///
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
    children.add(const SizedBox(height: 7));

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
