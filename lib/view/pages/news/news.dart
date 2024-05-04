import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:link4launches/view/pages/appbar.dart';
import 'package:link4launches/view/pages/components/box_image.dart';
import 'package:link4launches/view/pages/news/tempdata.dart';
import 'package:url_launcher/url_launcher.dart';

class SpaceNewsPage extends StatefulWidget {
  final L4LAppBar appBar;

  const SpaceNewsPage({
    required this.appBar,
    super.key,
  });

  @override
  State<SpaceNewsPage> createState() => _SpaceNewsPageState();
}

class _SpaceNewsPageState extends State<SpaceNewsPage> {
  Map<String, dynamic> news = json.decode(tempNews);

  @override
  Widget build(BuildContext context) => Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const L4LAppBar(actions: [
            // Refresh data by performing a new request to the api
            // IconButton(
            //     onPressed: () {
            //       setState(() => launches.clearData());
            //       _ll2API
            //           .launch(launchAmount)
            //           .then((value) => setState(() => launches = value));
            //     },
            //     icon: const Icon(Icons.autorenew)),
          ]),
        ],
        // Show the launches list only when the launchers obj is not empty
        body: ListView.builder(
          padding: EdgeInsets.zero,
          controller: ScrollController(),
          itemCount: (news['results'] as List).length,
          itemBuilder: (context, index) =>
              _buildListItem((news['results'] as List)[index]),
        ),
      ));

  Widget _buildListItem(Map<String, dynamic> item) => Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      margin: const EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InteractiveImage(
            imageLink: item['image_url'],
            fit: BoxFit.fitWidth,
          ),
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    item['title'],
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GestureDetector(
                  onTap: () => launchUrl(Uri.parse(item['url'])),
                  child: const Icon(
                    // change with \uf44c
                    Icons.link_outlined,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(158, 158, 158, 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  getLaunchDate(item['published_at']),
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              item['summary'],
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ));

  /// Formats a [String] containg the json date from ``'2023-08-24T06:47:59Z'`` to ``'24 / 08 / 2023'``.
  String getLaunchDate(String timeStamp) => timeStamp
      .split('T')[0]
      .split('-')
      .reversed
      .toString()
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll(', ', ' / ')
      .trim();

  /// Formats a [String] containg the json date from ``'2023-08-24T06:47:59Z'`` to ``'06 : 47'``.
  String getLaunchTime(String timeStamp) => timeStamp
      .split('T')[1]
      .split(':')
      .sublist(0, 2)
      .toString()
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll(', ', ' : ')
      .trim();
}
