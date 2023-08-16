import 'package:flutter/material.dart';
import 'package:link4launches/pages/launch/boxes/box.dart';
import 'package:link4launches/pages/ui_components/status.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class LaunchDataBox extends DataBox {
  final LaunchStatus? status;
  final String? padMapLink;

  const LaunchDataBox({
    super.key,
    required super.imageLink,
    required super.title,
    required this.status,
    required super.subTitle1,
    required super.subTitle2,
    required super.text,
    required this.padMapLink,
  });

  @override
  List<Widget> buildItemList(BuildContext context) => [
        if (isSafe(imageLink)) buildImageItem(imageLink!),
        buildTextItem(title, fontWeight: FontWeight.bold),
        if (status != null && isSafe(status!.state))
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: status,
          ),
        if (isSafe(subTitle1)) buildTextItem(subTitle1!, fontSize: 23),
        if (isSafe(subTitle2)) buildTextItem(subTitle2!, fontSize: 23),
        if (isSafe(text)) buildTextItem(text!, fontSize: 16),
        if (isSafe(padMapLink)) _buildPadItem(padMapLink!),
      ];

  Widget _buildPadItem(String link) => SizedBox(
        width: 80,
        child: TextButton(
            onPressed: () => launcher.launchUrl(Uri.parse(link)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined),
                Padding(
                  padding: EdgeInsets.fromLTRB(3.0, 0, 0, 0),
                  child: Text(
                    'Pad',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            )),
      );
}
