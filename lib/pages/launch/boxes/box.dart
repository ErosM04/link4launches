import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link4launches/constant.dart';
import 'package:link4launches/pages/launch/shimmer.dart';
import 'package:link4launches/pages/ui_components/brightness.dart';

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
            color: BrightnessDetector.isDarkCol(
                context, DARK_ELEMENT, LIGHT_ELEMENT),
            border: Border.all(
              width: 10,
              color: BrightnessDetector.isDarkCol(
                  context, DARK_ELEMENT, LIGHT_ELEMENT),
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

  Widget buildImageItem(String link) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: CachedNetworkImage(
          fadeOutDuration: const Duration(milliseconds: 400),
          imageUrl: link,
          placeholder: (context, url) => const Center(child: ShimmerBox()),
          errorWidget: (context, error, stackTrace) => Container(),
        ),
      ));

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
