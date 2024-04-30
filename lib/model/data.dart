/// This abstract class provides an extensible mould to store a ``Map<String, dynamic>`` object and easly
/// access and modify its content.
class DataMould {
  Map<String, dynamic> _data;

  DataMould({required Map<String, dynamic> data}) : _data = data;

  factory DataMould.empty() => DataMould(data: {});

  bool get isEmpty => _data.isEmpty;

  bool get isNotEmpty => _data.isNotEmpty;

  Map<String, dynamic> get fullData => _data;

  set updateData(Map<String, dynamic> newData) => _data = newData;

  getValueFromNestedMap({required List keys}) =>
      _nestedRecursiveAccess(dataStructure: _data, keys: keys);

  bool setValueInNestedMap({required element, required List keys}) =>
      _nestedRecursiveSet(dataStructure: _data, keys: keys, element: element);

  /// Recursive function used to access to a value in the nested [Map] ``[_data]``.
  _nestedRecursiveAccess({required dataStructure, required List keys}) {
    if ((dataStructure == null || keys.isEmpty) ||
        ((dataStructure is Map && dataStructure.isEmpty) ||
            (dataStructure is List && dataStructure.isEmpty))) return '';

    var res = dataStructure;
    try {
      res = dataStructure[keys.first];
    } catch (e) {
      return '';
    }

    if (keys.length == 1) return res;

    return _nestedRecursiveAccess(dataStructure: res, keys: keys.sublist(1));
  }

  bool _nestedRecursiveSet(
      {required dataStructure, required List keys, required element}) {
    if ((dataStructure == null || keys.isEmpty) ||
        ((dataStructure is Map && dataStructure.isEmpty) ||
            (dataStructure is List && dataStructure.isEmpty))) return false;
    try {
      if (keys.length == 1) {
        if (dataStructure is Map &&
            !dataStructure.containsKey(keys.first.toString())) {
          dataStructure.putIfAbsent(keys.first.toString(), () => element);
        } else {
          dataStructure[keys.first] = element;
        }
        return true;
      }
    } catch (e) {
      return false;
    }

    return _nestedRecursiveSet(
        dataStructure: dataStructure[keys.first],
        keys: keys.sublist(1),
        element: element);
  }

  /// Takes a [String] and converts it into an [int].
  /// If the string contains ``'.'`` then only the part from the start to the dot is saved.
  /// If anything goes wrong ``-1`` is returned.
  int convertToInt(String str) {
    try {
      if (str.contains('.')) {
        str = str.substring(0, str.indexOf('.'));
      }
      return (str.isEmpty) ? -1 : int.parse(str);
    } catch (e) {
      return -1;
    }
  }
}
