import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Creates a custom [Dialog].
class CustomDialog extends StatelessWidget {
  /// The path (of the assets) where thw icon image is stored
  final Image image;

  /// The title of the dialog.
  final String title;

  /// The widget representing the content of the dialog.
  /// This goes between the title (on top) and the action buttons (on bottom).
  final Widget child;

  /// The text to display inside the deny button
  final String denyButtonText;

  /// The text to display inside the confirm button
  final String confirmButtonText;

  /// The function to execute after the deny button is pressed
  final Function denyButtonAction;

  /// The function to execute after the confirm button is pressed
  final Function confirmButtonAction;

  /// If it's true then after either ``[denyButtonAction]`` or ``[confirmButtonAction]`` are executed,
  /// ``Navigator.pop(context);`` is called and the dialog is dismissed.
  final bool popAtActionEnd;

  const CustomDialog({
    super.key,
    required this.image,
    required this.title,
    required this.child,
    this.denyButtonText = 'No',
    this.confirmButtonText = 'Yes',
    required this.denyButtonAction,
    required this.confirmButtonAction,
    this.popAtActionEnd = true,
  });

  @override
  Widget build(BuildContext context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated image
            Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 81, 92, 110),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    image
                        .animate()
                        .rotate(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.linearToEaseOut,
                        )
                        .rotate(
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.linearToEaseOut,
                          begin: 1,
                          end: 0,
                        ),
                  ],
                ),
              ),
            ),
            // Title and child
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  child,
                ],
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        denyButtonAction();
                        Navigator.pop(context);
                      },
                      child: Text(denyButtonText)),
                  ElevatedButton(
                      onPressed: () {
                        confirmButtonAction();
                        Navigator.pop(context);
                      },
                      child: Text(confirmButtonText)),
                ],
              ),
            )
          ],
        ),
      );
}
