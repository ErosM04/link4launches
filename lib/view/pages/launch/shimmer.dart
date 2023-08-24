import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';
import 'package:shimmer/shimmer.dart';

/// A [Widget] that can be used while an image is laoding to display a shimmer effect. This shows a grey background with a light
/// grey diagonal row that moves from left to right and then re-apperas in the left.
class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        // Easteregg
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
