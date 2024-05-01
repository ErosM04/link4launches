/// Class used to provide an extensible mould to store a ``Map<String, dynamic>`` object and easly
/// access and modify its content.
class DataMould {
  /// The container for the data of the class.
  Map<String, dynamic> _data;

  DataMould({required Map<String, dynamic> data}) : _data = data;

  /// Creates a [DataMould] with empty [_data].
  factory DataMould.empty() => DataMould(data: {});

  bool get isEmpty => _data.isEmpty;

  bool get isNotEmpty => _data.isNotEmpty;

  Map<String, dynamic> get fullData => _data;

  set updateData(Map<String, dynamic> newData) => _data = newData;

  /// Returns a value contained in the data structure ``[_data]`` specified by the keys values used a parameters.
  /// If
  /// The function can use both [Map] keys and [List] indexes.
  ///
  /// E.g.:
  /// The function
  /// ```
  /// getValueFromNestedMap(keys: ["key1", "key2", 3, "key3", 0, "key4"]);
  /// ```
  /// Access to [_data] in the following way:
  /// ```
  /// _data["key1"]["key2"][3]["key3"][0]["key4"]
  /// ```
  ///
  /// #### Parameters:
  /// - ``List keys`` : the list containing the parameters.
  ///
  /// #### Returns:
  /// ``Dynamic`` : the element at the specified position.
  getValueFromNestedMap({required List keys}) =>
      _nestedRecursiveAccess(dataStructure: _data, keys: keys);

  /// Modify the value contained in the data structure ``[_data]`` specified by the keys values used a parameters
  /// with ``[element]``. If the last element of ``[keys]`` in the [Map] doesnt't exist it's created (as a key),
  /// then ``[element]`` is paired to that key.
  /// The function can use both [Map] keys and [List] indexes.
  ///
  /// E.g.:
  /// The function
  /// ```
  /// getValueFromNestedMap(keys: ["key1", "key2", 3, "key3", 0, "key4"], element: "cacca");
  /// ```
  /// THe update is of [_data] works the following way:
  /// ```
  /// _data["key1"]["key2"][3]["key3"][0]["key4"] = "cacca";
  /// ```
  ///
  ///  #### Parameters:
  /// - ``List keys`` : the list containing the parameters.
  /// - ``dynamic element`` : the element to insert or to use to modify an existing value.
  ///
  /// #### Returns:
  /// ``bool`` : true if no errors occurs, otherwise false.
  bool setValueInNestedMap({required element, required List keys}) =>
      _nestedRecursiveSet(dataStructure: _data, keys: keys, element: element);

  /// Recursive function used to access to a value in the nested [Map] ``[_data]``.
  /// The function access to the value of the data structure at the position specified by the first element
  /// of ``[keys]``, than calls itself passing the value obtained and the list without the first element.
  /// This process repeats until ``[keys]`` is empty. The last value obtained is returned. If no values is found
  /// or an error occures an empty [String] is returned.
  ///
  /// #### Parameters:
  /// - ``dynamic dataStructure`` : the dataStructure, either [Map] or [List];
  /// - ``List keys`` : the list containing the parameters.
  ///
  /// #### Results:
  /// ``dynamic`` : the elment at the specified position, or ``''`` if nothing was found or an error occurred.
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

  /// Recursive function used to modify a value in the nested [Map] ``[_data]`` with ``[element]``.
  /// The function access to the value of the data structure at the position specified by the first element
  /// of ``[keys]``, than calls itself passing the value obtained and the list without the first element.
  /// This process repeats until ``[keys]`` is empty. The last value is substituted with ``[element]``.
  /// If no errors occurs true is returned, otherwise is false.
  ///
  /// #### Parameters:
  /// - ``dynamic dataStructure`` : the dataStructure, either [Map] or [List];
  /// - ``List keys`` : the list containing the parameters.
  ///
  /// #### Results:
  /// ``bool`` : true if no errors occurs, otherwise false.
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
  /// If the string contains ``'.'`` the decimal part is excluded. If anything goes wrong ``-1`` is returned.
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
