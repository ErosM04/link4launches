import 'package:link4launches/model/data.dart';

/// Class the extends [DataMould] to create a daa manager to store the launches information retrived by the API
/// and keep tracking of the free API requests.
class Launches extends DataMould {
  /// The free remainig request that can be performed to the API.
  int _requestsLeft;

  Launches({
    required int availableRequests,
    required super.data,
  }) : _requestsLeft = availableRequests;

  /// Instantiates a [Launches] object with empty data.
  factory Launches.empty({required int availableRequests}) =>
      Launches(availableRequests: availableRequests, data: {});

  void clearData() => super.updateData = {};

  int get remainingRequests => _requestsLeft;

  void decreaseRequests() => _requestsLeft--;

  void setRequestsToZero() => _requestsLeft = 0;

  int get totalLaunches => getLaunchesList().length;

  // Main getters
  List<Map<String, dynamic>> getLaunchesList() =>
      getValueFromNestedMap(keys: ['results']);

  //  - Launch:
  String getShortStatus(int index) =>
      _getValueFromLaunch(index: index, keys: ['status', 'abbrev']).toString();

  String getLaunchName(int index) =>
      _getValueFromLaunch(index: index, keys: ['name']).toString();

  String getLaunchTimeStamp(int index) =>
      _getValueFromLaunch(index: index, keys: ['net']).toString();

  /// Formats a [String] containg the json date from ``'2023-08-24T06:47:59Z'`` to ``'24 / 08 / 2023'``.
  String getLaunchDate(int index) => getLaunchTimeStamp(index)
      .split('T')[0]
      .split('-')
      .reversed
      .toString()
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll(', ', ' / ')
      .trim();

  /// Formats a [String] containg the json date from ``'2023-08-24T06:47:59Z'`` to ``'06 : 47'``.
  String getLaunchTime(int index) => getLaunchTimeStamp(index)
      .split('T')[1]
      .split(':')
      .sublist(0, 2)
      .toString()
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll(', ', ' : ')
      .trim();

  String getLaunchImage(int index) =>
      _getValueFromLaunch(index: index, keys: ['image']).toString();

  String getLaunchMission(int index) =>
      _getValueFromLaunch(index: index, keys: ['mission', 'description'])
          .toString();

  String getLaunchPadLocation(int index) =>
      _getValueFromLaunch(index: index, keys: ['pad', 'map_url']).toString();

  // - Rocket Conf:
  String getLauncherUrl(int index) =>
      _getValueFromRocketConf(index: index, keys: ['url']).toString();

  String getLauncherId(int index) =>
      _getValueFromRocketConf(index: index, keys: ['id']).toString();

  String getLauncherName(int index) =>
      _getValueFromRocketConf(index: index, keys: ['name']).toString();

  String getLauncherFullName(int index) =>
      _getValueFromRocketConf(index: index, keys: ['full_name']).toString();

  Map<String, dynamic> getLauncherData(int index) =>
      _getValueFromLauncherData(index: index, keys: []);

  // - Launcher:
  String getLauncherImage(int index) =>
      _getValueFromLauncherData(index: index, keys: ['image_url']).toString();

  int getLauncherHeight(int index) => convertToInt(
      _getValueFromLauncherData(index: index, keys: ['length']).toString());

  int getLauncherMaxStages(int index) => convertToInt(
      _getValueFromLauncherData(index: index, keys: ['max_stage']).toString());

  int getLauncherLiftOffThrust(int index) => convertToInt(
      _getValueFromLauncherData(index: index, keys: ['to_thrust']).toString());

  int getLauncherLiftOffMass(int index) => convertToInt(
      _getValueFromLauncherData(index: index, keys: ['launch_mass'])
          .toString());

  int getLauncherLEOCapacity(int index) => convertToInt(
      _getValueFromLauncherData(index: index, keys: ['leo_capacity'])
          .toString());

  int getLauncherGTOCapacity(int index) => convertToInt(
      _getValueFromLauncherData(index: index, keys: ['gto_capacity'])
          .toString());

  int getLauncherSuccLaunches(int index) => convertToInt(
      _getValueFromLauncherData(index: index, keys: ['successful_launches'])
          .toString());

  int getLauncherFailedLaunches(int index) => convertToInt(
      _getValueFromLauncherData(index: index, keys: ['failed_launches'])
          .toString());

  String getLauncherDescription(int index) =>
      _getValueFromLauncherData(index: index, keys: ['description']).toString();

  // - Launcher Manufacturer:
  String getLaunchManLogo(int index) =>
      _getValueFromLauncherManufacturer(index: index, keys: ['logo_url'])
          .toString();

  String getLaunchManName(int index) =>
      _getValueFromLauncherManufacturer(index: index, keys: ['name'])
          .toString();

  String getLaunchManType(int index) =>
      _getValueFromLauncherManufacturer(index: index, keys: ['type'])
          .toString();

  String getLaunchManCountryCode(int index) =>
      _getValueFromLauncherManufacturer(index: index, keys: ['country_code'])
          .toString();

  String getLaunchManAD(int index) =>
      _getValueFromLauncherManufacturer(index: index, keys: ['administrator'])
          .toString();

  String getLaunchManDescription(int index) =>
      _getValueFromLauncherManufacturer(index: index, keys: ['description'])
          .toString();

  // Main setters
  bool addLauncherData(int index, {required Map<String, dynamic> data}) =>
      _setValueInLauncherData(index: index, keys: [], element: data);

  bool setLauncherCountryCode(int index, {required String newCC}) =>
      _setValueInLauncherData(
          index: index, keys: ['manufacturer', 'country_code'], element: newCC);

  // Private background getter
  _getValueFromLauncherManufacturer({required int index, required List keys}) =>
      _getValueFromLauncherData(index: index, keys: ['manufacturer', ...keys]);

  _getValueFromLauncherData({required int index, required List keys}) =>
      _getValueFromRocketConf(index: index, keys: ['data', ...keys]);

  _getValueFromRocketConf({required int index, required List keys}) =>
      _getValueFromLaunch(
          index: index, keys: ['rocket', 'configuration', ...keys]);

  _getValueFromLaunch({required int index, required List keys}) =>
      getValueFromNestedMap(keys: ['results', index, ...keys]);

  // Private background setters
  bool _setValueInLauncherData({
    required int index,
    required List keys,
    required element,
  }) =>
      _setValueInRocketConf(
          index: index, keys: ['data', ...keys], element: element);

  bool _setValueInRocketConf({
    required int index,
    required List keys,
    required element,
  }) =>
      _setValueInLaunch(
        index: index,
        keys: ['rocket', 'configuration', ...keys],
        element: element,
      );

  _setValueInLaunch({
    required int index,
    required List keys,
    required element,
  }) =>
      setValueInNestedMap(element: element, keys: ['results', index, ...keys]);
}
