import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/launch/components/box_image.dart';

/// An abstract class that defines the base structure for a box widget which contains an image and differents types of textual information.
/// All the null parameters won't be displayed.
abstract class DataBox extends StatelessWidget {
  /// The web link of the image. Usually displayed on top of the box.
  final String? imageLink;

  /// The title of the box. Usually displayed below the image.
  final String title;

  /// The first subtitle. Usually displayed below the title.
  final String? subTitle1;

  /// The second subtitle. Usually displayed below the first subtitle.
  final String? subTitle2;

  /// The text that describes the subject of the box. Usually on the bottom of the box.
  final String? text;

  const DataBox({
    super.key,
    this.imageLink,
    required this.title,
    this.subTitle1,
    this.subTitle2,
    this.text,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            border: Border.all(
              width: 10,
              color: Theme.of(context).colorScheme.secondary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20.0))),
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: buildItemList(),
        ),
      );

  /// Creates a List of Widget using the class variables, but only if those varaibles are not null and not empty.
  /// To build the widgets uses other class methods.
  List<Widget> buildItemList() => [
        if (isSafe(imageLink)) InteractiveImage(imageLink!),
        buildTextItem(title, fontWeight: FontWeight.bold),
        if (isSafe(subTitle1)) buildTextItem(subTitle1!, fontSize: 21),
        if (isSafe(subTitle2)) buildTextItem(subTitle2!, fontSize: 21),
        if (isSafe(text)) buildTextItem(text!, fontSize: 16),
      ];

  /// Creates a [Text] item (with [Padding]) and customization to build titles, subtitles and normal text
  ///
  /// #### Parameters
  /// - ``String [str]`` : the text to display.
  /// - ``double [fontSize]`` : the font size of the text (default is 23 [for titles]).
  /// - ``FontWeight [fontWeight]`` : the weight of the font (default is normal).
  Widget buildTextItem(
    String str, {
    double fontSize = 23,
    FontWeight fontWeight = FontWeight.normal,
  }) =>
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          str,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      );

  /// Can be used to check whether a value is usable, meaning that it's neither null nor false.
  ///
  /// #### Parameters
  /// - ``String? [str]`` : the string to check.
  ///
  /// #### Returns
  /// - ``bool`` : true if the string isn't both null and empty.
  bool isSafe(String? str) => (str != null && str.isNotEmpty) ? true : false;
}
