import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link4launches/constant.dart';
import 'package:link4launches/pages/brightness.dart';

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
        elevation: 0, // removes shadow
        behavior: SnackBarBehavior.floating,
        width: double.infinity,
        duration: (durationInMil == null)
            ? Duration(seconds: durationInSec)
            : Duration(milliseconds: durationInMil!),
        backgroundColor: Colors.transparent,
        content: Container(
          height: (message.length <= 40) ? 45 : 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: BrightnessDetector.isDarkCol(
              context,
              Colors.black,
              const Color.fromARGB(255, 240, 240, 240),
            ),
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
            child: _getContent(context),
          ),
          const SizedBox(width: 3),
        ],
      );

  Text _getContent(BuildContext context) => Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: BrightnessDetector.isDarkCol(
                context, LIGHT_ELEMENT, const Color.fromARGB(255, 47, 48, 49))),
      );
}
