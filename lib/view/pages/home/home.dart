import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link4launches/logic/api/api.dart';
import 'package:link4launches/logic/updater/updater.dart';
import 'package:link4launches/view/pages/components/launch%20state/status.dart';
import 'package:link4launches/view/pages/components/launch%20state/small_status.dart';
import 'package:link4launches/view/pages/home/launch_tile.dart';
import 'package:link4launches/view/pages/launch/launch.dart';
import 'package:link4launches/view/pages/appbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// The home page of the app. Uses [LaunchLibrary2API] to fetch the data and [Updater] to look for the latest version.
class L4LHomePage extends StatefulWidget {
  /// The name of the launch, composed by the name of the launcher and the name of the payload, separated by '|'.
  /// E.g. ``Falcon 9 Block 5 | Starlink Group 6-22``.
  final String title;

  const L4LHomePage({super.key, required this.title});

  @override
  State<L4LHomePage> createState() => _L4LHomePageState();
}

class _L4LHomePageState extends State<L4LHomePage> {
  /// Object used to manage api interactions.
  late final LaunchLibrary2API _ll2API;

  /// Map used to save api retrived data.
  Map<String, dynamic> data = {};

  /// Amount of upcoming launches to requesto to the api.
  final int launchAmount = 14;

  /// Whether to show the launches which state is TBD (To Be Defined).
  /// This varaible is managed by an [IconButton] contained in the [L4LAppBar].
  bool showTBD = true;

  /// Object used to manage the update of the app.
  late Updater updater;

  /// Reusable appbar for launch pages.
  final L4LAppBar launchAppBar = const L4LAppBar();

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

  /// Redirects to the launch page for the specific launch. Only if [data] is not empty.
  ///
  /// #### Parameters
  /// - ``int [index]`` : the position of the launch in the list inside ``data['results']``.
  /// - ``LaunchStatus [status]`` : the status small [widget] to use in the launch page.
  void _goToLaunchInfo(int index, LaunchState status) {
    if (data.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LaunchInfoPage(
                data: data['results'][index],
                status: status,
                appBar: launchAppBar,
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
          ]),
        ],
        body: data.isEmpty
            ? Center(
                child: LoadingAnimationWidget.dotsTriangle(
                    color: Colors.white, size: 50))
            : ListView.builder(
                padding: EdgeInsets.zero,
                controller: ScrollController(),
                itemCount: data['count'],
                itemBuilder: (context, index) => _buildListItem(index),
              ),
      ));

  /// Builds the single ``[LaunchTile]`` of the list.
  ///
  /// #### Parameters
  /// - ``int [index]`` : the position of the launch in the list inside ``data['results']``.
  Widget _buildListItem(int index) => LaunchTile(
        onPressed: () => _goToLaunchInfo(index,
            LaunchState(state: data['results'][index]['status']['abbrev'])),
        condition:
            (data['results'][index]['status']['abbrev'] == 'TBD' && !showTBD),
        title: data['results'][index]['name'],
        smallText: _clearDate(data['results'][index]['net'].toString()),
        status: SmallLaunchStatus(
            state: data['results'][index]['status']['abbrev']),
      );

  /// Removes all the unwanted characters from the date of the json and reverse it.
  ///
  /// #### Parameters
  /// - ``String [str]`` : the [String] containg the date if the json.
  ///
  /// #### Returns
  /// ``String`` : the reversed string without the unwanted characters and in the correct format.
  String _clearDate(String str) => str
      .split('T')[0]
      .split('-')
      .reversed
      .toString()
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll(', ', ' / ');
}
