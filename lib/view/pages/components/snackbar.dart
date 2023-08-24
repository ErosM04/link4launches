import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom [SnackBar] containg a custom icon (path in the assets) in the left and the text at the center.
class CustomSnackBar {
  /// The message to display as text in the center of the [SnackBar].
  final String message;

  /// For how many seconds the [SnackBar] is displayed, doesn't work if [_durationInMil] isn't null.
  final int _durationInSec;

  /// For how many milliseconds the [SnackBar] is displayed.
  final int? _durationInMil;

  const CustomSnackBar({
    required this.message,
    int durationInSec = 3,
    int? durationInMil,
    double fontSize = 15,
  })  : _durationInMil = durationInMil,
        _durationInSec = durationInSec;

  /// Allows to create the [CustomSnackBar] widget, this method must be called after creating the [Widget].
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
