import 'package:flutter/material.dart';
import 'package:link4launches/snackbar.dart';

class LaunchStatus extends StatelessWidget {
  final String state;
  final double fontSize;

  const LaunchStatus({super.key, required this.state, this.fontSize = 25});

  @override
  Widget build(BuildContext context) => _buildStatusWidget(
        context,
        state.toUpperCase(),
        _getStatusBoxWidth(state.length),
      );

  Widget buildSmallStatusBedge(BuildContext context) => _buildStatusWidget(
      context,
      _resizeStatus(state),
      _getSmallStatusBoxWidth(_resizeStatus(state).length),
      height: 28,
      fontSizeReduction: 6);

  Widget _buildStatusWidget(BuildContext context, String state, double width,
          {double height = 40, double fontSizeReduction = 0}) =>
      GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBarMessage(message: _getStatusDescription(state))
                .build(context)),
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

  String _resizeStatus(String state) =>
      (state.toUpperCase().contains('IN FLIGHT'))
          ? 'FLIG'
          : (state.length > 4)
              ? state.toUpperCase().substring(0, 4)
              : state.toUpperCase();

  String _getStatusDescription(String state) {
    if (state == 'GO') {
      return 'Ready To Go';
    } else if (state == 'TBC') {
      return 'To Be Confirmed';
    } else if (state == 'TBD') {
      return 'To Be Defined';
    } else if (state == 'SUCC' || state == 'SUCCESS') {
      return 'Launch Successful';
    } else if (state == 'FAIL' || state == 'FAILED') {
      return 'Launch Failed';
    } else if (state == 'FLIG' || state == 'IN FLIGHT') {
      return 'Rocket actually In Flight';
    } else {
      return 'Undefined';
    }
  }

  Color? _getStatusColor(String state) {
    if (state == 'GO') {
      return Colors.green[900];
    } else if (state == 'TBC') {
      return Colors.orange[900];
    } else if (state == 'TBD' || state == 'FAIL' || state == 'FAILED') {
      return Colors.red[800];
    } else if (state == 'SUCC' || state == 'SUCCESS') {
      return Colors.green[600];
    } else if (state == 'FLIG' || state == 'IN FLIGHT') {
      return Colors.deepPurple[600];
    } else {
      return Colors.blue;
    }
  }

  double _getStatusBoxWidth(int length) =>
      (length < 5) ? (length * ((length < 3) ? 26 : 23)) : length * 18;

  double _getSmallStatusBoxWidth(int length) =>
      (length < 3) ? length * 20 : length * 16;
}
