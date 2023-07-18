import 'package:flutter/material.dart';
import 'package:link4launches/constant.dart';
import 'package:link4launches/pages/home.dart';

void main() => runApp(const Link4Launches());

class Link4Launches extends StatelessWidget {
  const Link4Launches({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: APP_NAME,
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        // theme: L4Ltheme,
        home: const L4LHomePage(title: APP_NAME),
      );
}
