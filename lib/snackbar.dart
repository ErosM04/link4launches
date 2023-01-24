import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SnackBarMessage {
  final String message;
  final int duration;
  final double fontSize;

  const SnackBarMessage({
    required this.message,
    this.duration = 2,
    this.fontSize = 15,
  });

  SnackBar build(BuildContext context) => SnackBar(
        content: _getContent(
            MediaQuery.of(context).platformBrightness == Brightness.dark),
        duration: Duration(seconds: duration),
        backgroundColor: _getBackgroundColor(
            MediaQuery.of(context).platformBrightness == Brightness.dark),
      );

  SnackBar buildWhitoutContext() => SnackBar(
        content: _getContent(
            SchedulerBinding.instance.window.platformBrightness ==
                Brightness.dark),
        duration: Duration(seconds: duration),
        backgroundColor: _getBackgroundColor(
            SchedulerBinding.instance.window.platformBrightness ==
                Brightness.dark),
      );

  Widget _getContent(bool isDark) => Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
            // fontSize: fontSize,
            color: _getTextColor(isDark)),
      );

  Color _getTextColor(bool isDark) =>
      isDark ? Colors.white : const Color.fromARGB(255, 47, 48, 49);

  Color _getBackgroundColor(bool isDark) => isDark
      ? const Color.fromARGB(255, 51, 52, 53)
      : const Color.fromARGB(255, 240, 240, 240);
}
