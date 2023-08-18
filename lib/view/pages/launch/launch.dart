import 'package:flutter/material.dart';
import 'package:link4launches/view/app_bar.dart';
import 'package:link4launches/view/pages/launch/boxes/agency_box.dart';
import 'package:link4launches/view/pages/launch/boxes/launch_box.dart';
import 'package:link4launches/view/pages/launch/boxes/rocket_box.dart';
import 'package:link4launches/view/pages/ui_components/status.dart';

class LaunchInfoPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final LaunchStatus status;

  const LaunchInfoPage({
    super.key,
    required this.data,
    required this.status,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
          // backgroundColor: BrightnessDetector.isDarkCol(
          //     context, DARK_BACKGROUND, LIGHT_BACKGROUND),
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

  List<Widget> _buildDataBoxList() => [
        // First container (launch data)
        LaunchDataBox(
          imageLink: _readJsonField(['image']),
          title: data['name'],
          status: status,
          subTitle1: _formatDate(_readJsonField(['net']), 0),
          subTitle2: _formatTime(_readJsonField(['net']), 1),
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

  int _convertToInt(String str) {
    try {
      if (str.contains('.')) {
        str = str.substring(0, str.indexOf('.'));
      }

      return (str == '') ? -1 : int.parse(str);
    } on FormatException catch (_) {
      return -1;
    }
  }

  /// Thakes a list of keys and then checks if the value corresponding with the sequence of keys
  /// (in the data Map) exists and returns it as a string. The list can't have more than 5 elements.
  ///
  /// #### Parameters:
  /// - **``list``** : a list of String, where wach string is a key of the json Map, e.g. ``['rocket', 'configuration', 'url', 'description']``
  ///
  /// ### Returns
  /// The value corresponding to the keys position as a String, e.g. ``data['rocket']['configuration']['url']['description']``
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

  String _formatDate(String str, int index) {
    List<String> list = str.replaceAll('Z', '').split('T')[index].split('-');
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

  String _formatTime(String str, int index) {
    List<String> list = str.replaceAll('Z', '').split('T')[index].split(':');
    return '${list[0]} : ${list[1]}';
  }
}
