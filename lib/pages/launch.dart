import 'package:flutter/material.dart';
import 'package:link4launches/constant.dart';
import 'package:link4launches/pages/app_bar.dart';
import 'package:link4launches/pages/box.dart';
import 'package:link4launches/pages/brightness.dart';
import 'package:link4launches/pages/status.dart';

class LaunchInfoPage extends StatelessWidget {
  final L4LAppBar appbar;
  final Map<String, dynamic> data;
  final LaunchStatus status;

  const LaunchInfoPage(
      {super.key,
      required this.appbar,
      required this.data,
      required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: BrightnessDetector.isDarkCol(
            context, DARK_BACKGROUND, LIGHT_BACKGROUND),
        appBar: AppBar(
          title: Text(appbar.title),
          backgroundColor: appbar.color,
          actions: [
            appbar.getPopUpMenuButton(),
          ],
        ),
        body: ListView(
          children: _buildDataBoxList(),
        ));
  }

  List<DataBox> _buildDataBoxList() {
    List<DataBox> list = [];

    //First container (launch)
    if (_readJsonField(['name']).isNotEmpty) {
      list.add(DataBox(
        imageLink: _readJsonField(['image']),
        title: data['name'],
        status: status,
        h1: _formatDate(_readJsonField(['net']), 0),
        h2: _formatTime(_readJsonField(['net']), 1),
        text: _readJsonField(['mission', 'description']),
        containsDate: true,
        padLink: _readJsonField(['pad', 'map_url']),
      ));
    }

    //Second container (agency)
    if (_readJsonField(
            ['rocket', 'configuration', 'url', 'manufacturer', 'name'])
        .isNotEmpty) {
      list.add(DataBox(
        imageLink: _readJsonField(
            ['rocket', 'configuration', 'url', 'manufacturer', 'logo_url']),
        title: data['rocket']['configuration']['url']['manufacturer']['name'],
        h1: _readJsonField(
            ['rocket', 'configuration', 'url', 'manufacturer', 'type']),
        h2: _readJsonField([
          'rocket',
          'configuration',
          'url',
          'manufacturer',
          'administrator'
        ]),
        text: _readJsonField(
            ['rocket', 'configuration', 'url', 'manufacturer', 'description']),
      ));
    }

    //Third container (rocket)
    if (_readJsonField(['rocket', 'configuration', 'url', 'name']).isNotEmpty) {
      list.add(DataBox(
        imageLink: (_readJsonField(
                    ['rocket', 'configuration', 'url', 'image_url']) ==
                _readJsonField(['image']))
            ? ''
            : _readJsonField(['rocket', 'configuration', 'url', 'image_url']),
        title: data['rocket']['configuration']['url']['name'],
        h1: (_readJsonField(['rocket', 'configuration', 'url', 'full_name']) ==
                data['rocket']['configuration']['url']['name'])
            ? ''
            : _readJsonField(['rocket', 'configuration', 'url', 'full_name']),
        height: _convertToInt(
            _readJsonField(['rocket', 'configuration', 'url', 'length'])),
        maxStages: _convertToInt(
            _readJsonField(['rocket', 'configuration', 'url', 'max_stage'])),
        liftoffThrust: _convertToInt(
            _readJsonField(['rocket', 'configuration', 'url', 'to_thrust'])),
        liftoffMass: _convertToInt(
            _readJsonField(['rocket', 'configuration', 'url', 'launch_mass'])),
        massToLEO: _convertToInt(
            _readJsonField(['rocket', 'configuration', 'url', 'leo_capacity'])),
        massToGTO: _convertToInt(
            _readJsonField(['rocket', 'configuration', 'url', 'gto_capacity'])),
        successfulLaunches: _convertToInt(_readJsonField(
            ['rocket', 'configuration', 'url', 'successful_launches'])),
        failedLaunches: _convertToInt(_readJsonField(
            ['rocket', 'configuration', 'url', 'failed_launches'])),
        text: _readJsonField(['rocket', 'configuration', 'url', 'description']),
      ));
    }

    return list;
  }

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
