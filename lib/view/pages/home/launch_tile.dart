import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/components/launch%20state/small_status.dart';

/// [StatelessWidget] used to create the tile of a single launch in the home page.
class LaunchTile extends StatelessWidget {
  /// The function to execute when the tile is pressed.
  final Function onPressed;

  /// The condition that allows the tile to be hidden.
  final bool condition;

  /// The title of the tile.
  final String title;

  /// The smaller text below the title (used for the date).
  final String smallText;

  /// The [Widget] used to create the staus icon at the right.
  final SmallLaunchStatus status;

  const LaunchTile({
    super.key,
    required this.onPressed,
    required this.condition,
    required this.title,
    required this.smallText,
    required this.status,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onPressed(),
        child: (condition)
            ? Container()
            : Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18))),
                margin: const EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 7.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 0, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 17),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            smallText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                      child: status,
                    )
                  ],
                )),
      );
}
