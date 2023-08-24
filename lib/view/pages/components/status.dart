import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';

/// Class used to manage the [Widget] of the launch status ('To Be Defined', 'Ready To Go'...). Can create both a small and a
/// big version of the status icon, respectively for the home page and for the launch page.
class LaunchStatus extends StatelessWidget {
  /// The text that identify the status (like 'GO').
  final String state;

  /// The font size for the status text.
  final double fontSize;

  const LaunchStatus({super.key, required this.state, this.fontSize = 25});

  /// Uses [_buildStatusWidget] to create the big status version for the launch page
  @override
  Widget build(BuildContext context) => _buildStatusWidget(
        context,
        state.toUpperCase(),
        _getStatusBoxWidth(state.length),
      );

  /// Creates the big status version for the launch page
  ///
  /// #### Parameters
  /// - ``BuildContext [context]`` : the context used to invoke the [CustomSnackBar]
  /// - ``String state`` : the text describing the state
  /// - ``double width`` : the width of the state [Widget]
  /// - ``double height`` : the height of the state [Widget]
  /// - ``double fontSizeReduction `` : whether reduce or no the font size (for small version)
  Widget _buildStatusWidget(BuildContext context, String state, double width,
          {double height = 40, double fontSizeReduction = 0}) =>
      GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(message: _getStatusDescription(state)).build()),
        child: Stack(
          fit: StackFit.loose,
          alignment: AlignmentDirectional.center,
          children: [
            Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                    color: _getStatusColor(state))),
            Text(
              state,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize - fontSizeReduction,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

  /// Used to create the small version of the status [Widget].
  ///
  /// #### Parameters
  /// - ``BuildContext context`` : the app context to invoke the [CustomSnackBar].
  Widget buildSmallStatusBedge(BuildContext context) => _buildStatusWidget(
      context,
      _resizeStatusName(state),
      _getSmallStatusBoxWidth(_resizeStatusName(state).length),
      height: 28,
      fontSizeReduction: 6);

  /// Returns a smaller version of the status name.
  ///
  /// #### Parameters
  /// - ``String [state]`` : the text of the status.
  ///
  /// #### Returns
  /// - ``String`` : the reduced text of the status. Usually a substring of 4 letters, except for 'IN FLIGHT' and 'PARTIAL FAILURE'.
  String _resizeStatusName(String state) {
    state = state.toUpperCase();

    if (state.contains('IN FLIGHT')) {
      return 'FLIG';
    } else if (state.contains('PARTIAL FAILURE')) {
      return 'PTFL';
    } else {
      return (state.length > 4) ? state.substring(0, 4) : state;
    }
  }

  /// Based on the state text returns its description.
  ///
  /// #### Parameters
  /// - ``String [state]`` : the text of the status.
  ///
  /// #### Returns
  /// - ``String`` : the description of the state.
  String _getStatusDescription(String state) {
    if (state == 'GO') {
      return 'Ready to Go for Launch';
    } else if (state == 'TBC') {
      return 'To Be Confirmed - Awaiting official confirmation';
    } else if (state == 'TBD') {
      return 'To Be Defined';
    } else if (state == 'SUCC' || state == 'SUCCESS') {
      return 'Launch Successful';
    } else if (state == 'FAIL' || state == 'FAILED' || state == 'FAILURE') {
      return 'Launch Failed';
    } else if (state == 'PTFL' || state == 'PARTIAL FAILURE') {
      return 'Either a Partial Failure or an exceptional event made it impossible to consider the mission a success';
    } else if (state == 'FLIG' || state == 'IN FLIGHT') {
      return 'Rocket actually In Flight';
    } else if (state == 'HOLD' || state == 'ON HOLD') {
      return 'The launch has been paused, but it can still happen within the launch window.';
    } else {
      return 'Undefined';
    }
  }

  /// Based on the state text returns its color.
  ///
  /// #### Parameters
  /// - ``String [state]`` : the text of the status.
  ///
  /// #### Returns
  /// - ``String`` : the specific color of the state. If there are no matches blue is returned.
  Color? _getStatusColor(String state) {
    if (state == 'GO') {
      return Colors.green[900];
    } else if (state == 'TBC') {
      return Colors.orange[900];
    } else if (state == 'TBD' ||
        state == 'FAIL' ||
        state == 'FAILED' ||
        state == 'FAILURE' ||
        state == 'PTFL' ||
        state == 'PARTIAL FAILURE') {
      return Colors.red[800];
    } else if (state == 'SUCC' || state == 'SUCCESS') {
      return Colors.green[600];
    } else if (state == 'FLIG' || state == 'IN FLIGHT') {
      return Colors.deepPurple[600];
    } else if (state == 'HOLD' || state == 'ON HOLD') {
      return Colors.purpleAccent[400];
    } else {
      return Colors.blue;
    }
  }

  /// Returns the width of the status [Widget] based on the length of the text status for the big version.
  double _getStatusBoxWidth(int length) =>
      (length < 5) ? (length * ((length < 3) ? 26 : 23)) : length * 18;

  /// Returns the width of the status [Widget] based on the length of the text status for the small version.
  double _getSmallStatusBoxWidth(int length) =>
      (length < 3) ? length * 20 : length * 16;
}
