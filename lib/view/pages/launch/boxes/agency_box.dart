import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link4launches/view/pages/launch/boxes/box.dart';

class AgencyDataBox extends DataBox {
  final String countryCode;

  const AgencyDataBox({
    super.key,
    required super.imageLink,
    required super.title,
    required super.subTitle1,
    required this.countryCode,
    required super.subTitle2,
    required super.text,
  });

  @override
  List<Widget> buildItemList(BuildContext context) => [
        if (isSafe(imageLink)) buildImageItem(imageLink!),
        buildTextItem(title, fontWeight: FontWeight.bold),
        if (isSafe(subTitle1) && isSafe(imageLink))
          _buildTextWithCountryFlag(text: subTitle1!, imageLink: imageLink!)
        else if (isSafe(subTitle1))
          buildTextItem(subTitle2!, fontSize: 21),
        if (isSafe(subTitle2)) buildTextItem(subTitle2!, fontSize: 21),
        if (isSafe(text)) buildTextItem(text!, fontSize: 16),
      ];

  Widget _buildTextWithCountryFlag({
    required String text,
    required String imageLink,
  }) =>
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21),
            ),
            const SizedBox(width: 5),
            Container(
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 5),
            SvgPicture.network(
              'https://flagcdn.com/${countryCode.toLowerCase()}.svg',
              width: 32,
            ),
          ],
        ),
      );
}
