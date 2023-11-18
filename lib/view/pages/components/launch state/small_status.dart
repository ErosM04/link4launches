import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/components/launch%20state/status.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';

/// Creates a customizable [Widget] that represent the launch state showed in the home page ('TBD', 'GO', 'TBC', ...).
/// This widget overrides [LaunchState] by creating a smaller version of the [Widget].
class SmallLaunchStatus extends LaunchState {
  const SmallLaunchStatus({
    super.key,
    required super.state,
  });

  /// Overrided method that uses ``[widgetBuilder]`` to create a custom icon of the state.
  /// In this case a smaller version of the [Widget] is created by overriding the [buildStatusWidget] of the parent class ([LaunchState]).
  ///
  /// #### Parameters
  /// - ``BuildContext [context]`` : the app context for [widgetBuilder] to call the [CustomSnackBar].
  ///
  /// #### Returns:
  /// - ``Widget`` : the status widget created by [widgetBuilder].
  @override
  Widget buildStatusWidget(BuildContext context) => widgetBuilder(
        context,
        _cropStatusName(state),
        getStatusBoxWidth(_cropStatusName(state).length),
        height: 28,
        fontSize: 19,
      );

  /// Returns a smaller version of the status name.
  ///
  /// #### Parameters
  /// - ``String [state]`` : the text of the status.
  ///
  /// #### Returns
  /// - ``String`` : the reduced text of the status. Usually a substring of 4 letters, except for 'IN FLIGHT' and 'PARTIAL FAILURE'.
  String _cropStatusName(String state) {
    state = state.toUpperCase();

    if (state.contains('IN FLIGHT')) {
      return 'FLIG';
    } else if (state.contains('PARTIAL FAILURE')) {
      return 'PTFL';
    } else {
      return (state.length > 4) ? state.substring(0, 4) : state;
    }
  }

  /// Returns the width of the status [Widget] based on the length of the status name (like 'GO').
  ///
  /// #### Parameters
  /// - ``int [length]`` : the length of the cropped name, meaning that was processed by [_cropStatusName]. E.g. 'TBD', 'GO', 'FLIG'.
  ///
  /// #### Returns
  /// ``double`` : the width of the status [Widget].
  @override
  double getStatusBoxWidth(int length) =>
      (length < 3) ? length * 20 : length * 16;
}
