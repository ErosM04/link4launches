import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:link4launches/pages/ui_components/snackbar.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class LaunchLibrary2API {
  Map<String, dynamic> data = {};
  final String backupFile = 'll2data.json';
  final String link;
  var context;

  LaunchLibrary2API({required this.link});

  Future<Map<String, dynamic>> launch(int limit) async {
    int statusCode = -1;
    String reasonPhrase = '', body = '';

    try {
      var response = await http.get(Uri.parse('$link&limit=$limit'));

      if (response.statusCode == 200) {
        data = json.decode(convertGibberish(
            response.body.replaceAll("\r", "").replaceAll("\n", "")));
        data['count'] = _getItemCount(); //Sets the right number of launches
        data = await _fetchRocket(data, _getItemCount());
        _writeJsonFile(json.encode(data));
        return data;
      } else {
        statusCode = response.statusCode;
        reasonPhrase = response.reasonPhrase ?? '';
        body = response.body;
      }
    } on Exception catch (_) {}

    // Throttled request (15 requests limit per hour exceeded), reads backup file
    ScaffoldMessenger.of(context).showSnackBar(SnackBarMessage(
            message:
                'Error${(statusCode != -1) ? ' $statusCode' : ''} ${(reasonPhrase.isEmpty) ? body.replaceAll('{', '').replaceAll('}', '').replaceAll('"detail":', '').replaceAll('"', '') : ': due to $reasonPhrase'}')
        .build(context));
    data = json.decode(await _loadFromFile(context));

    return data;
  }

  Future<Map<String, dynamic>> _fetchRocket(
      Map<String, dynamic> map, int total) async {
    Map<String, dynamic> backup = {};
    try {
      backup = json.decode(await _loadFromFile(context, showSnackBar: false));
    } on Exception catch (_) {}

    try {
      List<dynamic> linkList = [];
      for (int i = 0; i < total; i++) {
        var link = map['results'][i]['rocket']['configuration']['url'];
        int pos = _findRecurrence(linkList, link);
        /*Uses data from backup if this rocket configuration is already contained.
          Otherwise if the data are not containe but the fetch was already performed, reuse these data.
          If the data are not present a fetch is performed.
          Using this if whenever an element is remove, the backup loading won't work, this allows to rocket conf. data*/
        if (backup.isNotEmpty &&
            i < backup['count'] &&
            backup['results'][i]['rocket']['configuration']['id'] ==
                map['results'][i]['rocket']['configuration']['id'] &&
            backup['results'][i]['rocket']['configuration']['url'] !=
                map['results'][i]['rocket']['configuration']['url']) {
          map['results'][i]['rocket']['configuration']['url'] =
              backup['results'][i]['rocket']['configuration']['url'];
        } else if (pos != -1) {
          // If the rocket configuration already exists in the map (previous fetch)
          map['results'][i]['rocket']['configuration']['url'] =
              map['results'][pos]['rocket']['configuration']['url'];
        } else {
          var res = await http.get(Uri.parse(link));
          if (res.statusCode == 200) {
            map['results'][i]['rocket']['configuration']['url'] = json.decode(
                convertGibberish(
                    res.body.replaceAll("\r", "").replaceAll("\n", "")));

            // Changes the country code format
            String countryCode = await _fetchCountryCode(map['results'][i]
                        ['rocket']['configuration']['url']['manufacturer']
                    ['country_code']
                .toString());
            map['results'][i]['rocket']['configuration']['url']['manufacturer']
                ['country_code'] = countryCode;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBarMessage(
                    message:
                        'Error: ${res.statusCode} ${(res.reasonPhrase!.isEmpty) ? '' : 'due to ${res.reasonPhrase} '}for ${data['results'][i]['rocket']['configuration']['full_name']}')
                .build(context));
          }
        }

        // Add link for _findRecurrence() so as not to execute redundant fetches
        linkList.add(link);
      }
    } on Exception catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBarMessage(message: 'Cannot load launchers data')
              .build(context));
    }
    return map;
  }

  /// Takes the cca3 country code (of the main api) and then use https://restcountries.com api to convert it to the cca2 format.
  ///
  /// #### Parameters
  /// - **``String``** : the cca3 country code, e.g. ``USA`` (United States of America).
  ///
  /// #### Returns
  /// **``async String``** : the cca2 country code.
  Future<String> _fetchCountryCode(String countryCode) async {
    try {
      var response = await http
          .get(Uri.parse('https://restcountries.com/v3.1/alpha/$countryCode'));

      if (response.statusCode == 200) {
        return json
            .decode(response.body.replaceAll("\r", "").replaceAll("\n", ""))[0]
                ['cca2']
            .toString();
      } else {
        return '';
      }
    } on Exception catch (_) {
      return '';
    }
  }

  int _findRecurrence(List<dynamic> list, link) {
    for (int i = 0; i < list.length; i++) {
      if (list[i] == (link)) {
        return i;
      }
    }
    return -1;
  }

  int _getItemCount() {
    int tot = 0;
    try {
      for (int i = 0; i < data['count']; i++) {
        if (data['results'][i] != null) tot += 1;
      }
    } on Error catch (_) {}
    return tot;
  }

  Future<String> _loadFromFile(context, {bool showSnackBar = true}) async {
    try {
      if (await _existsJsonFile()) {
        if (showSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBarMessage(message: 'Data loaded from backup file')
                  .build(context));
        }
        return await _readJsonFile();
      }
    } on Exception catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBarMessage(message: 'Cannot load backup file')
            .build(context));
    return '';
  }

  Future<File> _getJsonFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$backupFile');
  }

  Future<bool> _existsJsonFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return (await File('${dir.path}/$backupFile').exists()) ? true : false;
  }

  Future<String> _readJsonFile() async {
    final File file = await _getJsonFile();
    return file.readAsString();
  }

  void _writeJsonFile(String content) async {
    final File file = await _getJsonFile();
    file.writeAsString(content);
  }

  String convertGibberish(String str) => str
      .replaceAll('Ã©', 'é')
      .replaceAll(' | Unknown Payload', '')
      .replaceAll('â', '–')
      .replaceAll('Î±', 'α');
}
