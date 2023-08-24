import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link4launches/view/pages/launch/components/box_image.dart';
import 'package:link4launches/view/pages/launch/components/boxes/box.dart';

/// Box Widget that creates an usable version of [DataBox] for the company/agency data.
class AgencyDataBox extends DataBox {
  /// The cc2a country code of the company/agency, like ``US`` or ``IT``.
  /// Doesn't need to be upper or lower case.
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
  List<Widget> buildItemList() => [
        if (isSafe(imageLink)) InteractiveImage(imageLink!),
        buildTextItem(title, fontWeight: FontWeight.bold),
        if (isSafe(subTitle1) && isSafe(imageLink))
          _buildTextWithCountryFlag(text: subTitle1!, imageLink: imageLink!)
        else if (isSafe(subTitle1))
          buildTextItem(subTitle2!, fontSize: 21),
        if (isSafe(subTitle2)) buildTextItem(subTitle2!, fontSize: 21),
        if (isSafe(text)) buildTextItem(text!, fontSize: 16),
      ];

  /// Creates a [Row] containing the type of the company/agency (like ``Goverantive`` or ``Commercial``) on the left and the
  /// country flag on the right using the [Flagpedia](https://flagpedia.net) api. E.g. ``https://flagcdn.com/us.svg``.
  ///
  /// #### Parameters
  /// - ``String [text]`` :
  /// - ``String [imageLink]`` :
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
