import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link4launches/logic/api/api.dart';
import 'package:link4launches/logic/updater/updater.dart';
import 'package:link4launches/view/pages/components/launch%20state/status.dart';
import 'package:link4launches/view/pages/components/launch%20state/small_status.dart';
import 'package:link4launches/view/pages/home/launch_tile.dart';
import 'package:link4launches/view/pages/launch/launch.dart';
import 'package:link4launches/view/pages/appbar.dart';
import 'package:link4launches/view/pages/news/news.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:link4launches/model/launches.dart';

/// The home page of the app. Uses [LaunchLibrary2API] to fetch the data and [Updater] to look for the latest version.
class L4LHomePage extends StatefulWidget {
  /// The name of the app to display in the ``[L4LAppBar]``.
  final String title;

  const L4LHomePage({super.key, required this.title});

  @override
  State<L4LHomePage> createState() => _L4LHomePageState();
}

class _L4LHomePageState extends State<L4LHomePage> {
  /// Object used to manage Launch Libray 2 API interactions.
  late final LaunchLibrary2API _ll2API;

  /// Object that uses a [Map] to save the API retrived data.
  Launches launches = Launches.empty(availableRequests: 0);

  /// Amount of upcoming launches to request to the api (not all of them will be displayed depending on
  /// how much launchers data cna be retrived using the free requests).
  /// For more info go to [api logic](.\lib\logic\api\api.dart).
  final int launchAmount = 50;

  /// Whether to show the launches which state is TBD (To Be Defined).
  /// This varaible is managed by an [IconButton] contained in the [L4LAppBar].
  bool showTBD = true;

  /// Reusable appbar for launch pages.
  final L4LAppBar launchAppBar = const L4LAppBar();

  @override
  void initState() {
    super.initState();

    // Creates a api Object and performs a request
    _ll2API = LaunchLibrary2API(
      context: context,
    );
    _ll2API
        .launch(launchAmount)
        .then((value) => setState(() => launches = value));

    //Orientation lock in portrait (vertical) mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Checks if a new version exists and asks for download consent.
    // The 2 seconds delay is to avoid errors (trust me).
    // Probably because without the delay, the push of the consent dialog would
    // be performed before the completion of the initState().
    Future.delayed(
      const Duration(seconds: 2),
      () => Updater(context).updateToNewVersion(),
    );
  }

  /// Redirects to the launch page for the specific launch. Only if tha data of that specific launch
  /// contained in the ``[launches]`` onject exists.
  ///
  /// #### Parameters
  /// - ``int [index]`` : the position of the launch in the list of launches contained in [launches].
  /// - ``LaunchStatus [status]`` : the small launch status used in the launch page.
  void _goToLaunchInfo(int index, LaunchState status) {
    if (launches.getLaunchesList()[index].isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LaunchInfoPage(
                launches: launches,
                launchIndex: index,
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
            // Redirects to Space News page
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SpaceNewsPage(appBar: launchAppBar),
                    )),
                // change with \uf1ea
                icon: const Icon(Icons.newspaper_rounded)),
            // Refresh data by performing a new request to the api
            IconButton(
              onPressed: () {
                setState(() => launches.clearData());
                _ll2API
                    .launch(launchAmount)
                    .then((value) => setState(() => launches = value));
              },
              icon: const Icon(Icons.autorenew),
            ),
          ]),
        ],
        // Show the launches list only when the launchers obj is not empty
        body: launches.isEmpty
            ? Center(
                child: LoadingAnimationWidget.dotsTriangle(
                    color: Colors.white, size: 50))
            : ListView.builder(
                padding: EdgeInsets.zero,
                controller: ScrollController(),
                itemCount: launches.totalLaunches,
                itemBuilder: (context, index) => _buildListItem(index),
              ),
      ));

  /// Builds a ``[LaunchTile]`` that is going to be part of the list.
  ///
  /// #### Parameters
  /// - ``int [index]`` : the position of the launch in the list of launches contained in [launches].
  Widget _buildListItem(int index) => LaunchTile(
        onPressed: () => _goToLaunchInfo(
            index, LaunchState(state: launches.getShortStatus(index))),
        condition: (launches.getShortStatus(index) == 'TBD' && !showTBD),
        title: launches.getLaunchName(index),
        date: launches.getLaunchDate(index),
        status: SmallLaunchStatus(state: launches.getShortStatus(index)),
      );
}
