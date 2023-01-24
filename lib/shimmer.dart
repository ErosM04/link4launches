import 'package:flutter/material.dart';
import 'package:link4launches/snackbar.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBarMessage(
                  message: 'Chill out dude', fontSize: 18) //Easteregg
              .build(context))),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Shimmer.fromColors(
            baseColor: Colors.grey[600]!,
            highlightColor: Colors.grey[500]!,
            child: Container(color: Colors.grey[600])),
      ),
    );
  }
}
