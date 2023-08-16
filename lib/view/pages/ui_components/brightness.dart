import 'package:flutter/material.dart';

class BrightnessDetector {
  const BrightnessDetector();

  static Color isDarkCol(
          BuildContext context, Color trueColor, Color falseColor) =>
      MediaQuery.of(context).platformBrightness == Brightness.dark
          ? trueColor
          : falseColor;

  static Color isLightCol(
          BuildContext context, Color trueColor, Color falseColor) =>
      MediaQuery.of(context).platformBrightness == Brightness.light
          ? trueColor
          : falseColor;

  static double isDarkNum(
          BuildContext context, double trueNum, double falseNum) =>
      MediaQuery.of(context).platformBrightness == Brightness.dark
          ? trueNum
          : falseNum;

  static double isLightNum(
          BuildContext context, double trueNum, double falseNum) =>
      MediaQuery.of(context).platformBrightness == Brightness.light
          ? trueNum
          : falseNum;
}
