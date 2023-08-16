import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link4launches/logic/api/api.dart';
import 'package:link4launches/constant.dart';
import 'package:link4launches/view/app_bar.dart';
import 'package:link4launches/view/pages/ui_components/brightness.dart';
import 'package:link4launches/view/pages/home/launch_tile.dart';
import 'package:link4launches/view/pages/launch/launch.dart';
import 'package:link4launches/view/pages/ui_components/status.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class L4LHomePage extends StatefulWidget {
  final String title;

  const L4LHomePage({super.key, required this.title});

  @override
  State<L4LHomePage> createState() => _L4LHomePageState();
}

class _L4LHomePageState extends State<L4LHomePage> {
  final LaunchLibrary2API _ll2API = LaunchLibrary2API(
      link: 'https://ll.thespacedevs.com/2.2.0/launch/upcoming/?format=json');
  final _scrollController = ScrollController();
  final int launchNumber = 14;
  bool showTBD = true;

  _L4LHomePageState() {
    _ll2API.launch(launchNumber).then((value) => setState(() => _ll2API.data));
  }

  @override
  void initState() {
    super.initState();

    //Orientation lock in portrait (vertical) mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Checks if a new version exists and asks for download consent.
    // The 2 seconds delay is to avoid errors (trust me).
    // Probably because without the delay, the push of the consent dialog would
    // be performed before the completion of the initState()
    // Updater updater = Updater(context);
    // Future.delayed(
    //   const Duration(seconds: 2),
    //   () => updater.updateToNewVersion(),
    // );
  }

  void _goToInfo(int index, LaunchStatus status) {
    if (_ll2API.data.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LaunchInfoPage(
                data: _ll2API.data['results'][index],
                status: status,
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    _ll2API.context = context;
    return Scaffold(
        backgroundColor: BrightnessDetector.isDarkCol(
            context, DARK_BACKGROUND, LIGHT_BACKGROUND),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            L4LAppBar(actions: [
              IconButton(
                onPressed: () => setState(() => showTBD = !showTBD),
                icon: Text(
                  'TBD',
                  style: TextStyle(color: showTBD ? Colors.white : Colors.grey),
                ),
              ),
              IconButton(
                  onPressed: () => {
                        setState(() => _ll2API.data = {}),
                        _ll2API
                            .launch(launchNumber)
                            .then((value) => setState(() => _ll2API.data))
                      },
                  icon: const Icon(Icons.autorenew)),
            ]).buildAppBar(),
          ],
          body: _ll2API.data.isEmpty
              ? Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                      color: Colors.white, size: 50))
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  controller: _scrollController,
                  itemCount: _ll2API.data['count'],
                  itemBuilder: (context, index) => _buildListItem(index),
                ),
        ));
  }

  Widget _buildListItem(int index) {
    final LaunchStatus status =
        LaunchStatus(state: _ll2API.data['results'][index]['status']['abbrev']);

    return LaunchTile(
      onPressed: () => _goToInfo(index, status),
      condition: (_ll2API.data['results'][index]['status']['abbrev'] == 'TBD' &&
          !showTBD),
      title: _ll2API.data['results'][index]['name'],
      smallText: _cleanDate(_ll2API.data['results'][index]['net'].toString()),
      status: status,
    );
  }

  String _cleanDate(String str) => str
      .split('T')[0]
      .split('-')
      .reversed
      .toString()
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll(', ', ' / ');
}
