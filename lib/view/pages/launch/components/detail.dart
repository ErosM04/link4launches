import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';

/// Creates a small section containg details about a rocket condifuration.
/// Uses 2 by 2 cofiguration like this:
/// ```
/// ----------------------------------------
/// detail1 : value          detail2 : value
/// detail3 : value          detail4 : value
/// detail5 : value          detail6 : value
/// ...
/// ----------------------------------------
/// ```
class DetailSection extends StatelessWidget {
  /// The list of detail's values.
  final List<int> valuesList;

  const DetailSection({super.key, required this.valuesList});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Divider(thickness: 2),
          Column(children: _buildColumnChildren(context)),
          const Divider(thickness: 2),
        ],
      );

  /// Creates the column with all the children
  ///
  /// #### Parameters
  /// - ``BuildContext [context]`` : the app context for ``[_buildRow]``.
  List<Widget> _buildColumnChildren(BuildContext context) {
    List<Widget> list = [];

    for (int i = 0; i < valuesList.length; i += 2) {
      list.add(_buildRow(i, context));
    }

    return list;
  }

  /// Creates the row containg one detail at the start and one at the end.
  ///
  /// #### Parameters
  /// - ``int [index]`` : the position in the list of the first detail.
  /// - ``BuildContext [context]`` : the app context for ``[_buildDetail]``.
  Widget _buildRow(int index, BuildContext context) => Row(children: [
        _buildDetail(index, TextAlign.left, context),
        _buildDetail(index + 1, TextAlign.right, context)
      ]);

  /// Creates the single detail text with the name (using ``[_getName]``), the value (using ``[valuesList]`` and ``[index]``)
  /// and the unit (using ``[_getUnit]``). Every detail is a clickable text that displayed a [CustomSnackBar] containg the
  /// description of that value (using ``[_getDescription]``).
  ///
  /// #### Parameters
  /// - ``int [index]`` : the position in the of the detail.
  /// - ``TextAlign [alignment]`` : the alignment of the text
  /// - ``BuildContext [context]`` : the app context to invoke the ``[CustomSnackBar]``.
  Widget _buildDetail(int index, TextAlign alignment, BuildContext context) {
    String title = _getName(index);
    String value = _formatNumber(valuesList[index]);
    String unit = _getUnit(title);

    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: (() => ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(message: _getDescription(title), durationInSec: 4)
                .build())),
        child: Text(
          '$title: $value$unit',
          textAlign: alignment,
          style: const TextStyle(fontSize: 13.5),
        ),
      ),
    ));
  }

  /// Takes a position in ``[valuesList]`` and returns the corresponding name of the detail.
  String _getName(int pos) {
    switch (pos) {
      case 0:
        return 'Height';
      case 1:
        return 'Max Stages';
      case 2:
        return 'Liftoff Thrust';
      case 3:
        return 'Liftoff Mass';
      case 4:
        return 'Mass to LEO';
      case 5:
        return 'Mass to GTO';
      case 6:
        return 'Successf. Launches';
      case 7:
        return 'Failed Launches';
      default:
        return 'Undefined';
    }
  }

  /// Takes a number and if it's equal to ``-1`` returns a ``'---'`` otherwise returns the number as a [String].
  String _formatNumber(int value) => (value == -1) ? '---' : value.toString();

  /// Takes a position in ``[valuesList]`` and returns the corresponding name of the detail.
  String _getUnit(String str) {
    if (str.contains('Height')) {
      return 'm';
    } else if (str.contains('Liftoff Thrust')) {
      return 'kN';
    } else if (str.contains('Liftoff Mass')) {
      return 't';
    } else if (str.contains('Mass to LEO') || str.contains('Mass to GTO')) {
      return 'kg';
    } else {
      return '';
    }
  }

  /// Takes a position in ``[valuesList]`` and returns the corresponding name of the detail.
  String _getDescription(String str) {
    switch (str) {
      case 'Height':
        return 'The height of the rocket';
      case 'Max Stages':
        return 'The maximum number of stages the rocket can have';
      case 'Liftoff Thrust':
        return 'Thrust generated during the liftoff';
      case 'Liftoff Mass':
        return 'Mass of the rocket during the liftoff';
      case 'Mass to LEO':
        return 'Playload mass that the rocket is able to carry into the Low Earth Orbit, from 200 up to 2,000 km';
      case 'Mass to GTO':
        return 'Playload mass that the rocket is able to carry into the Geostationary Transfer Orbit (35,786 km)';
      case 'Successf. Launches':
        return 'Total successful launches performed';
      case 'Failed Launches':
        return 'Total failed launches';
      default:
        return 'Undefined';
    }
  }
}
