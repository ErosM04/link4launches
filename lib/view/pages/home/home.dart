import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link4launches/logic/api/api.dart';
import 'package:link4launches/logic/updater/updater.dart';
import 'package:link4launches/view/pages/app_bar.dart';
import 'package:link4launches/view/pages/home/launch_tile.dart';
import 'package:link4launches/view/pages/launch/launch.dart';
import 'package:link4launches/view/pages/components/status.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class L4LHomePage extends StatefulWidget {
  final String title;

  const L4LHomePage({super.key, required this.title});

  @override
  State<L4LHomePage> createState() => _L4LHomePageState();
}

class _L4LHomePageState extends State<L4LHomePage> {
  late final LaunchLibrary2API _ll2API;
  Map<String, dynamic> data = {};
  final _scrollController = ScrollController();
  final int launchAmount = 14;
  bool showTBD = true;
  late Updater updater;

  @override
  void initState() {
    super.initState();

    // Creates a api Object and perform a request
    _ll2API = LaunchLibrary2API(
      link: 'https://ll.thespacedevs.com/2.2.0/launch/upcoming/?format=json',
      context: context,
    );
    _ll2API.launch(launchAmount).then((value) => setState(() => data = value));

    //Orientation lock in portrait (vertical) mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Checks if a new version exists and asks for download consent.
    // The 2 seconds delay is to avoid errors (trust me).
    // Probably because without the delay, the push of the consent dialog would
    // be performed before the completion of the initState()
    updater = Updater(context);
    Future.delayed(
      const Duration(seconds: 2),
      () => updater.updateToNewVersion(),
    );
  }

  void _goToLaunchInfo(int index, LaunchStatus status) {
    if (data.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LaunchInfoPage(
                data: data['results'][index],
                status: status,
              )));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          L4LAppBar(actions: [
            // Hides the TBD launches
            IconButton(
              onPressed: () => setState(() => showTBD = !showTBD),
              icon: Text(
                'TBD',
                style: TextStyle(color: showTBD ? Colors.white : Colors.grey),
              ),
            ),
            // Refresh data by performing a new request to the api
            IconButton(
                onPressed: () => {
                      setState(() => data = {}),
                      _ll2API
                          .launch(launchAmount)
                          .then((value) => setState(() => data = value))
                    },
                icon: const Icon(Icons.autorenew)),
          ]).buildAppBar(),
        ],
        body: data.isEmpty
            ? Center(
                child: LoadingAnimationWidget.dotsTriangle(
                    color: Colors.white, size: 50))
            : ListView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                itemCount: data['count'],
                itemBuilder: (context, index) => _buildListItem(index),
              ),
      ));

  Widget _buildListItem(int index) {
    final LaunchStatus status =
        LaunchStatus(state: data['results'][index]['status']['abbrev']);

    return LaunchTile(
      onPressed: () => _goToLaunchInfo(index, status),
      condition:
          (data['results'][index]['status']['abbrev'] == 'TBD' && !showTBD),
      title: data['results'][index]['name'],
      smallText: _clearDate(data['results'][index]['net'].toString()),
      status: status,
    );
  }

  String _clearDate(String str) => str
      .split('T')[0]
      .split('-')
      .reversed
      .toString()
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll(', ', ' / ');
}
