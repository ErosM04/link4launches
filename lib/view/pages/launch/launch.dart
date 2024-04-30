import 'package:flutter/material.dart';
import 'package:link4launches/model/launches.dart';
import 'package:link4launches/view/pages/components/launch%20state/status.dart';
import 'package:link4launches/view/pages/launch/components/boxes/agency_box.dart';
import 'package:link4launches/view/pages/launch/components/boxes/box.dart';
import 'package:link4launches/view/pages/launch/components/boxes/launch_box.dart';
import 'package:link4launches/view/pages/launch/components/boxes/rocket_box.dart';
import 'package:link4launches/view/pages/appbar.dart';

/// Is the second page of the app, that depends on the launch it is releated to.
/// This page is used to display different [DataBox] containg informations about the launchm the agency/company an the rocket.
class LaunchInfoPage extends StatelessWidget {
  final Launches launches;

  final int launchIndex;

  /// The [Widget] used to create the status icon.
  final LaunchState status;

  /// Custom [SliverAppBar].
  final L4LAppBar appBar;

  const LaunchInfoPage({
    super.key,
    required this.launches,
    required this.launchIndex,
    required this.status,
    required this.appBar,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [appBar],
        body: ListView(
          padding: EdgeInsets.zero,
          children: _buildDataBoxList(),
        ),
      ));

  /// Uses the information contained in [data] to build the 3 different containers:
  /// ``[LaunchDataBox]``, ``[AgencyDataBox]`` and ``[RocketDataBox]``.
  /// To avoid exception with un-existing json fields, the values are read with ``[_readJsonField]``.
  List<Widget> _buildDataBoxList() => [
        // First container (launch data)
        LaunchDataBox(
          imageLink: launches.getLaunchImage(launchIndex),
          title: launches.getLaunchName(launchIndex),
          status: status,
          subTitle1: launches.getLaunchDate(launchIndex),
          subTitle2: launches.getLaunchTime(launchIndex),
          text: launches.getLaunchMission(launchIndex),
          padMapLink: launches.getLaunchPadLocation(launchIndex),
        ),

        //Second container (agency data)
        AgencyDataBox(
          imageLink: launches.getLaunchManLogo(launchIndex),
          title: launches.getLaunchManName(launchIndex),
          subTitle1: launches.getLaunchManType(launchIndex),
          countryCode: launches.getLaunchManCountryCode(launchIndex),
          subTitle2: launches.getLaunchManAD(launchIndex),
          text: launches.getLaunchManDescription(launchIndex),
        ),

        //Third container (rocket data)
        RocketDataBox(
          imageLink: (launches.getLauncherImage(launchIndex) ==
                  launches.getLaunchImage(launchIndex))
              ? ''
              : launches.getLauncherImage(launchIndex),
          title: launches.getLauncherName(launchIndex),
          subTitle1: (launches.getLauncherName(launchIndex) ==
                  launches.getLauncherFullName(launchIndex))
              ? ''
              : launches.getLauncherFullName(launchIndex),
          height: launches.getLauncherHeight(launchIndex),
          maxStages: launches.getLauncherMaxStages(launchIndex),
          liftoffThrust: launches.getLauncherLiftOffThrust(launchIndex),
          liftoffMass: launches.getLauncherLiftOffMass(launchIndex),
          massToLEO: launches.getLauncherLEOCapacity(launchIndex),
          massToGTO: launches.getLauncherGTOCapacity(launchIndex),
          successfulLaunches: launches.getLauncherSuccLaunches(launchIndex),
          failedLaunches: launches.getLauncherFailedLaunches(launchIndex),
          text: launches.getLaunchManDescription(launchIndex),
        ),
      ];
}
