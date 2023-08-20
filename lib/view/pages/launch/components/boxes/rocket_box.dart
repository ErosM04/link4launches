import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/launch/components/boxes/box.dart';
import 'package:link4launches/view/pages/launch/components/detail.dart';

class RocketDataBox extends DataBox {
  final int? height;
  final int? maxStages;
  final int? liftoffThrust;
  final int? liftoffMass;
  final int? massToLEO;
  final int? massToGTO;
  final int? successfulLaunches;
  final int? failedLaunches;

  const RocketDataBox({
    super.key,
    required super.imageLink,
    required super.title,
    required super.subTitle1,
    required this.height,
    required this.maxStages,
    required this.liftoffThrust,
    required this.liftoffMass,
    required this.massToLEO,
    required this.massToGTO,
    required this.successfulLaunches,
    required this.failedLaunches,
    required super.text,
  });

  @override
  List<Widget> buildItemList(BuildContext context) => [
        if (isSafe(imageLink)) buildImageItem(imageLink!),
        buildTextItem(title, fontWeight: FontWeight.bold),
        if (isSafe(subTitle1)) buildTextItem(subTitle1!, fontSize: 21),
        DetailSection(
          valuesList: [
            height!,
            maxStages!,
            liftoffThrust!,
            liftoffMass!,
            massToLEO!,
            massToGTO!,
            successfulLaunches!,
            failedLaunches!,
          ],
        ),
        if (isSafe(text)) buildTextItem(text!, fontSize: 16),
      ];
}
