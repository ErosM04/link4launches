import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/launch/components/box_image.dart';
import 'package:link4launches/view/pages/launch/components/boxes/box.dart';
import 'package:link4launches/view/pages/launch/components/detail.dart';

/// Box Widget that creates an usable version of [DataBox] for the rocket configuration data.
/// To create the detailed secontion uses [DetailSection].
class RocketDataBox extends DataBox {
  /// Height of the rocket (in m).
  final int? height;

  /// Max amount of stages the rocket can have.
  final int? maxStages;

  /// Thrust of the rocket during the lift off (in kN).
  final int? liftoffThrust;

  /// Weight of the rocket during the lift off (in t).
  final int? liftoffMass;

  /// Payload mass that the rocket can carry up to LEO orbit (in kg).
  final int? massToLEO;

  /// Payload mass that the rocket can carry up to GTO orbit (in kg).
  final int? massToGTO;

  /// Number of successful launches of the rocket.
  final int? successfulLaunches;

  /// Number of failed launches of the rocket.
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
  List<Widget> buildItemList() => [
        if (isSafe(imageLink)) InteractiveImage(imageLink!),
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
