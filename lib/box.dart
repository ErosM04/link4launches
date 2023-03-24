import 'package:flutter/material.dart';
import 'package:link4launches/detail.dart';
import 'package:link4launches/shimmer.dart';
import 'package:link4launches/status.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:cached_network_image/cached_network_image.dart';

class DataBox extends StatelessWidget {
  final String imageLink;
  final String title;
  final String h1;
  final String h2;
  final String text;
  final LaunchStatus status;
  final bool containsDate;
  final String padLink;
  final int height;
  final int maxStages;
  final int liftoffThrust;
  final int liftoffMass;
  final int massToLEO;
  final int massToGTO;
  final int successfulLaunches;
  final int failedLaunches;

  const DataBox({
    super.key,
    required this.title,
    this.imageLink = '',
    this.h1 = '',
    this.h2 = '',
    this.text = '',
    this.status = const LaunchStatus(state: ''),
    this.containsDate = false,
    this.padLink = '',
    this.height = -1,
    this.maxStages = -1,
    this.liftoffThrust = -1,
    this.liftoffMass = -1,
    this.massToLEO = -1,
    this.massToGTO = -1,
    this.successfulLaunches = -1,
    this.failedLaunches = -1,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? const Color.fromARGB(255, 57, 58, 59)
                : const Color.fromARGB(255, 230, 230, 230),
            border: Border.all(
              width: 10,
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color.fromARGB(255, 57, 58, 59)
                      : const Color.fromARGB(255, 230, 230, 230),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20.0))),
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: _buildItemList(context),
        ),
      );

  List<Widget> _buildItemList(BuildContext context) {
    List<Widget> list = [];

    if (imageLink.isNotEmpty) list.add(_buildImageItem());

    list.add(_buildTextItem(title, fontWeight: FontWeight.bold));

    if (status.state.isNotEmpty) {
      list.add(Padding(
        padding: const EdgeInsets.all(10.0),
        child: status,
      ));
    }

    if (h1.isNotEmpty) {
      list.add(_buildTextItem(h1, fontSize: 21, isDate: containsDate));
    }

    if (h2.isNotEmpty) {
      list.add(_buildTextItem(h2, fontSize: 21, isDate: containsDate));
    }

    if (height != -1 ||
        maxStages != -1 ||
        liftoffThrust != -1 ||
        liftoffMass != -1 ||
        massToLEO != -1 ||
        massToGTO != -1 ||
        successfulLaunches != -1 ||
        failedLaunches != -1) {
      list.add(DetailSection(
        valuesList: [
          height,
          maxStages,
          liftoffThrust,
          liftoffMass,
          massToLEO,
          massToGTO,
          successfulLaunches,
          failedLaunches
        ],
      ));
    }

    if (text.isNotEmpty) list.add(_buildTextItem(text, fontSize: 16));

    if (padLink.isNotEmpty) list.add(_buildPadItem(padLink));

    return list;
  }

  Widget _buildImageItem() => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: CachedNetworkImage(
          fadeOutDuration: const Duration(milliseconds: 400),
          imageUrl: imageLink,
          placeholder: (context, url) => const Center(child: ShimmerBox()),
          errorWidget: (context, error, stackTrace) => Container(),
        ),
      ));

  Widget _buildTextItem(String str,
          {double fontSize = 23,
          FontWeight fontWeight = FontWeight.normal,
          bool isDate = false}) =>
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          str,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDate ? 23 : fontSize,
            fontWeight: fontWeight,
          ),
        ),
      );

  Widget _buildPadItem(String link) {
    return SizedBox(
      width: 80,
      child: TextButton(
          onPressed: () => launcher.launchUrl(Uri.parse(link)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
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
}
