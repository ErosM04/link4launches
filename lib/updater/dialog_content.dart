import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DialogContent extends StatelessWidget {
  final String mainText;
  final String? subTitle;
  final String? text;
  final String? linkText;
  final String? link;

  const DialogContent({
    super.key,
    required this.mainText,
    required this.subTitle,
    required this.text,
    this.linkText,
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
          (linkText != null &&
                  linkText!.isNotEmpty &&
                  link != null &&
                  link!.isNotEmpty)
              ? _buildText(linkText!)
              : Container(),
          (link != null && link!.isNotEmpty) ? _buildLink(link!) : Container(),
        ],
      );

  Text _buildText(String text, [bool isLink = false]) => (isLink)
      ? Text(text,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
          ))
      : Text(text);

  Widget _buildLink(String text) => GestureDetector(
        onTap: () => launchUrl(Uri.parse(
            'https://github.com/ErosM04/link4launches/releases/latest')),
        child: _buildText(text, true),
      );
}
