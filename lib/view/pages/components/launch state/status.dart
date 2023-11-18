import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/components/snackbar.dart';

/// Creates a customizable [Widget] that represent the launch state showed in the launch page ('TBD', 'GO', 'TBC', ...).
class LaunchState extends StatelessWidget {
  /// The text that identifies the status (like 'GO').
  final String state;

  const LaunchState({super.key, required this.state});

  @override
  Widget build(BuildContext context) => buildStatusWidget(context);

  /// Overridable method that uses ``[widgetBuilder]`` to create a custom icon of the state.
  /// In this case a standard version of the state is created.
  ///
  /// #### Parameters
  /// - ``BuildContext [context]`` : the app context for [widgetBuilder] to call the [CustomSnackBar].
  ///
  /// #### Returns:
  /// - ``Widget`` : the status widget created by [widgetBuilder].
  Widget buildStatusWidget(BuildContext context) => widgetBuilder(
        context,
        state.toUpperCase(),
        getStatusBoxWidth(state.length),
      );

  /// Creates a customizable [Widget] that represent the launch state.
  ///
  /// #### Parameters
  /// - ``BuildContext [context]`` : the context used to invoke the [CustomSnackBar];
  /// - ``String [state]`` : the text describing the state;
  /// - ``double [width]`` : the width of the state [Widget];
  /// - ``double [height]`` : the height of the state [Widget];
  /// - ``double [fontSize] `` : the font size of the text contained in the [Widget].
  Widget widgetBuilder(BuildContext context, String state, double width,
          {double height = 40, double fontSize = 25}) =>
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
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

  /// Returns the width of the status [Widget] based on the length of the status name (like 'GO').
  ///
  /// #### Parameters
  /// - ``int [length]`` : the length of the name. E.g. 'TBD', 'GO', 'SUCCESS'.
  ///
  /// #### Returns
  /// ``double`` : the width of the status [Widget].
  double getStatusBoxWidth(int length) =>
      (length < 5) ? (length * ((length < 3) ? 26 : 23)) : length * 18;

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
}
