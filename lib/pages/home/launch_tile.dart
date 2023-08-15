import 'package:flutter/material.dart';
import 'package:link4launches/constant.dart';
import 'package:link4launches/pages/ui_components/brightness.dart';
import 'package:link4launches/pages/ui_components/status.dart';

class LaunchTile extends StatelessWidget {
  final Function onPressed;
  final bool condition;
  final String title;
  final String smallText;
  final LaunchStatus status;

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
                color: BrightnessDetector.isDarkCol(
                    context, DARK_ELEMENT, LIGHT_ELEMENT),
                elevation: BrightnessDetector.isLightNum(context, 5, 0),
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
                                fontSize: 12, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                      child: status.buildSmallStatusBedge(context),
                    )
                  ],
                )),
      );
}
