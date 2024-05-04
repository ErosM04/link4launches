import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/launch/shimmer.dart';

/// Image that can be zoomed in with pinch that comes with animated automatic reverse (after being zoomed goes back to original
/// size of its own).
class InteractiveImage extends StatefulWidget {
  /// Web link of the image.
  final String imageLink;
  final BoxFit? fit;

  const InteractiveImage({required this.imageLink, this.fit, super.key});

  @override
  State<InteractiveImage> createState() => _InteractiveImageState();
}

class _InteractiveImageState extends State<InteractiveImage>
    with SingleTickerProviderStateMixin {
  /// Zoom controller
  late TransformationController _transformationController;

  /// Animation controller
  late AnimationController _animationController;

  /// Animation.
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() => _transformationController.value = _animation!.value);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1,
        maxScale: 4,
        onInteractionEnd: (details) => _resetAnimation(),
        child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: CachedNetworkImage(
                fadeOutDuration: const Duration(milliseconds: 400),
                imageUrl: widget.imageLink,
                fit: widget.fit,
                placeholder: (context, url) =>
                    const Center(child: ShimmerEffect()),
                errorWidget: (context, error, stackTrace) => Container(),
              ),
            )),
      );

  /// Automatically zooms out the image to its original size, after 400ms delay.
  void _resetAnimation() async => Future.delayed(
        const Duration(milliseconds: 400),
        () {
          _animation = Matrix4Tween(
            begin: _transformationController.value,
            end: Matrix4.identity(),
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ));
          _animationController.forward(from: 0);
        },
      );
}
