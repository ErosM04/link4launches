import 'package:flutter/material.dart';

class DialogContent extends StatelessWidget {
  final String mainText;
  final String? subTitle;
  final String? text;
  final String? link;

  const DialogContent({
    super.key,
    required this.mainText,
    required this.subTitle,
    required this.text,
    this.link,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(mainText),
          const SizedBox(height: 12),
          (subTitle != null && subTitle!.isNotEmpty)
              ? _buildText(subTitle!)
              : Container(),
          const SizedBox(height: 4),
          (text != null && text!.isNotEmpty) ? _buildText(text!) : Container(),
          const SizedBox(height: 8),
          (link != null && link!.isNotEmpty) ? _buildLink(link!) : Container(),
        ],
      );

  Text _buildText(String text) => Text(text);

  Widget _buildLink(String text) => GestureDetector(
        onTap: () => print('lol'),
        child: _buildText(text),
      );
}
