import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //Easteregg
      onTap: (() => ScaffoldMessenger.of(context).showSnackBar(
          const CustomSnackBar(message: 'Chill out dude', fontSize: 18)
              .build())),
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
