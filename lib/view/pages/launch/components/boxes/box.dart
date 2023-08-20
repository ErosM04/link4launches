import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/launch/components/box_image.dart';

abstract class DataBox extends StatelessWidget {
  final String? imageLink;
  final String title;
  final String? subTitle1;
  final String? subTitle2;
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
          children: buildItemList(context),
        ),
      );

  List<Widget> buildItemList(
    BuildContext context,
  ) =>
      [
        if (isSafe(imageLink)) buildImageItem(imageLink!),
        buildTextItem(title, fontWeight: FontWeight.bold),
        if (isSafe(subTitle1)) buildTextItem(subTitle1!, fontSize: 21),
        if (isSafe(subTitle2)) buildTextItem(subTitle2!, fontSize: 21),
        if (isSafe(text)) buildTextItem(text!, fontSize: 16),
      ];

  Widget buildImageItem(String link) => InteractiveImage(link);

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

  bool isSafe(String? str) => (str != null && str.isNotEmpty) ? true : false;
}
