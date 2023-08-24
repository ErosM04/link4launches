import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/app_bar.dart';
import 'package:link4launches/view/pages/launch/components/boxes/agency_box.dart';
import 'package:link4launches/view/pages/launch/components/boxes/box.dart';
import 'package:link4launches/view/pages/launch/components/boxes/launch_box.dart';
import 'package:link4launches/view/pages/launch/components/boxes/rocket_box.dart';
import 'package:link4launches/view/pages/components/status.dart';

/// Is the second page of the app, that depends on the launch it is releated to.
/// This page is used to display different [DataBox] containg informations about the launchm the agency/company an the rocket.
class LaunchInfoPage extends StatelessWidget {
  /// The map containg the data of that specific launch.
  final Map<String, dynamic> data;

  /// The Widget used to create the small status icon.
  final LaunchStatus status;

  const LaunchInfoPage({
    super.key,
    required this.data,
    required this.status,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const L4LAppBar(
            actions: [],
          ).buildAppBar(),
        ],
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
          imageLink: _readJsonField(['image']),
          title: data['name'],
          status: status,
          subTitle1: _extractDate(_readJsonField(['net'])),
          subTitle2: _extractTime(_readJsonField(['net'])),
          text: _readJsonField(['mission', 'description']),
          padMapLink: _readJsonField(['pad', 'map_url']),
        ),

        //Second container (agency data)
        AgencyDataBox(
          imageLink: _readJsonField(
              ['rocket', 'configuration', 'url', 'manufacturer', 'logo_url']),
          title: data['rocket']['configuration']['url']['manufacturer']['name'],
          subTitle1: _readJsonField(
              ['rocket', 'configuration', 'url', 'manufacturer', 'type']),
          countryCode: _readJsonField([
            'rocket',
            'configuration',
            'url',
            'manufacturer',
            'country_code'
          ]),
          subTitle2: _readJsonField([
            'rocket',
            'configuration',
            'url',
            'manufacturer',
            'administrator'
          ]),
          text: _readJsonField([
            'rocket',
            'configuration',
            'url',
            'manufacturer',
            'description'
          ]),
        ),

        //Third container (rocket data)
        RocketDataBox(
            imageLink:
                (_readJsonField(['rocket', 'configuration', 'url', 'image_url']) ==
                        _readJsonField(['image']))
                    ? ''
                    : _readJsonField(
                        ['rocket', 'configuration', 'url', 'image_url']),
            title: data['rocket']['configuration']['url']['name'],
            subTitle1:
                (_readJsonField(['rocket', 'configuration', 'url', 'full_name']) ==
                        data['rocket']['configuration']['url']['name'])
                    ? ''
                    : _readJsonField(
                        ['rocket', 'configuration', 'url', 'full_name']),
            height: _convertToInt(
                _readJsonField(['rocket', 'configuration', 'url', 'length'])),
            maxStages: _convertToInt(_readJsonField(
                ['rocket', 'configuration', 'url', 'max_stage'])),
            liftoffThrust: _convertToInt(_readJsonField(
                ['rocket', 'configuration', 'url', 'to_thrust'])),
            liftoffMass: _convertToInt(_readJsonField(
                ['rocket', 'configuration', 'url', 'launch_mass'])),
            massToLEO: _convertToInt(
                _readJsonField(['rocket', 'configuration', 'url', 'leo_capacity'])),
            massToGTO: _convertToInt(_readJsonField(['rocket', 'configuration', 'url', 'gto_capacity'])),
            successfulLaunches: _convertToInt(_readJsonField(['rocket', 'configuration', 'url', 'successful_launches'])),
            failedLaunches: _convertToInt(_readJsonField(['rocket', 'configuration', 'url', 'failed_launches'])),
            text: _readJsonField(['rocket', 'configuration', 'url', 'description'])),
      ];

  /// Takes a [String] and converts it into an [int].
  /// If the string contains ``'.'`` then only the part from the start to the dot is saved.
  /// If anything goes wrong ``-1`` is returned.
  int _convertToInt(String str) {
    try {
      if (str.contains('.')) {
        str = str.substring(0, str.indexOf('.'));
      }

      return (str.isEmpty) ? -1 : int.parse(str);
    } on FormatException catch (_) {
      return -1;
    }
  }

  /// Thakes a list of keys and then checks if the value corresponding with the sequence of keys (in the data Map) exists and
  /// returns it as a string. The list can't have more than 5 elements.
  ///
  /// #### Parameters:
  /// - ``List<String> [list]`` : a list of String, where wach string is a key of the json Map, e.g.
  /// ``['rocket', 'configuration', 'url', 'description']``. The max length of the list is ``5``.
  ///
  /// ### Returns
  /// ``String`` : The value corresponding to the keys position as a String, e.g. ``data['rocket']['configuration']['url']['description']``
  /// In case of error an Exception is thrown and a empty String is returned.
  String _readJsonField(List<String> list) {
    try {
      if (list.isEmpty) {
        return '';
      } else if (list.length == 1 && list[0].isNotEmpty) {
        return data[list[0]].toString();
      } else if (list.length == 2 && list[0].isNotEmpty && list[1].isNotEmpty) {
        return data[list[0]][list[1]].toString();
      } else if (list.length == 3 &&
          list[0].isNotEmpty &&
          list[1].isNotEmpty &&
          list[2].isNotEmpty) {
        return data[list[0]][list[1]][list[2]].toString();
      } else if (list.length == 4 &&
          list[0].isNotEmpty &&
          list[1].isNotEmpty &&
          list[2].isNotEmpty &&
          list[3].isNotEmpty) {
        return data[list[0]][list[1]][list[2]][list[3]].toString();
      } else if (list.length == 5 &&
          list[0].isNotEmpty &&
          list[1].isNotEmpty &&
          list[2].isNotEmpty &&
          list[3].isNotEmpty &&
          list[4].isNotEmpty) {
        return data[list[0]][list[1]][list[2]][list[3]][list[4]].toString();
      } else {
        return '';
      }
    } on Error catch (_) {
      return '';
    }
  }

  /// Formats a [String] containg the json date from ``'2023-08-24T06:47:59Z'`` to ``'24-08-2023'``.
  String _extractDate(String str) {
    List<String> list = str.replaceAll('Z', '').split('T')[0].split('-');
    str = '';

    for (int i = list.length - 1; i >= 0; i--) {
      if (i == 0) {
        str += list[i];
      } else {
        str += '${list[i]} / ';
      }
    }

    return str;
  }

  /// Formats a [String] containg the json date from ``'2023-08-24T06:47:59Z'`` to ``'06 : 47'``.
  String _extractTime(String str) {
    List<String> list = str.replaceAll('Z', '').split('T')[1].split(':');
    return '${list[0]} : ${list[1]}';
  }
}
