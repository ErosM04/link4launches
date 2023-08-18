import 'package:flutter/material.dart';
import 'package:link4launches/view/pages/home/home.dart';
import 'package:link4launches/view/theme.dart';

void main() => runApp(const Link4Launches());

class Link4Launches extends StatelessWidget {
  const Link4Launches({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Link4Launches',
        theme: l4lLightTheme,
        darkTheme: l4lDarkTheme,
        home: const L4LHomePage(title: 'Link4Launches'),
        debugShowCheckedModeBanner: false,
      );
}
