import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SnackBarMessage {
  final String message;
  final int durationInSec;
  final int? durationInMil;
  final double fontSize;

  const SnackBarMessage({
    required this.message,
    this.durationInSec = 3,
    this.durationInMil,
    this.fontSize = 15,
  });

  SnackBar build(BuildContext context) => SnackBar(
        behavior: SnackBarBehavior.floating,
        width: double.infinity,
        duration: (durationInMil == null)
            ? Duration(seconds: durationInSec)
            : Duration(milliseconds: durationInMil!),
        backgroundColor: Colors.transparent,
        content: Container(
          height: _getSnackbarHeight(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: _getBackgroundColor(
                MediaQuery.of(context).platformBrightness == Brightness.dark),
          ),
          child: _buildSnackBarContent(context),
        ),
      );

  Widget _buildSnackBarContent(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 1),
            child: SvgPicture.asset(
              'assets/snackbar/space_devs_rocket.svg',
              height: 35,
              width: 35,
            ),
          ),
          Expanded(
            child: _getContent(
                MediaQuery.of(context).platformBrightness == Brightness.dark),
          ),
          const SizedBox(width: 3),
        ],
      );

  Text _getContent(bool isDark) => Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: _getTextColor(isDark)),
      );

  double _getSnackbarHeight() => (message.length <= 40) ? 45 : 70;

  Color _getTextColor(bool isDark) =>
      isDark ? Colors.white : const Color.fromARGB(255, 47, 48, 49);

  Color _getBackgroundColor(bool isDark) =>
      isDark ? Colors.black : const Color.fromARGB(255, 240, 240, 240);
}
