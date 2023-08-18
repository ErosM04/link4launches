import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSnackBar {
  final String message;
  final int _durationInSec;
  final int? _durationInMil;

  const CustomSnackBar({
    required this.message,
    int durationInSec = 3,
    int? durationInMil,
    double fontSize = 15,
  })  : _durationInMil = durationInMil,
        _durationInSec = durationInSec;

  SnackBar build() => SnackBar(
        duration: (_durationInMil == null)
            ? Duration(seconds: _durationInSec)
            : Duration(milliseconds: _durationInMil!),
        content: Row(
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
              child: Text(
                message,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 3),
          ],
        ),
      );
}
