import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/launch/shimmer.dart';

class InteractiveImage extends StatefulWidget {
  final String imageLink;

  const InteractiveImage(this.imageLink, {super.key});

  @override
  State<InteractiveImage> createState() => _InteractiveImageState();
}

class _InteractiveImageState extends State<InteractiveImage>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
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
                placeholder: (context, url) =>
                    const Center(child: ShimmerBox()),
                errorWidget: (context, error, stackTrace) => Container(),
              ),
            )),
      );

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
