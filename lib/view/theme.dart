import 'package:flutter/material.dart';

/// Dark theme for Link4Launches app.
ThemeData l4lDarkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: Color.fromARGB(255, 27, 28, 29),
    primary: Color.fromARGB(255, 3, 101, 140),
    onPrimary: Colors.white,
    secondary: Color.fromARGB(255, 57, 58, 59),
    onSecondary: Colors.white,
    tertiary: Color.fromARGB(255, 151, 151, 151),
  ),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 3, 101, 140),
    elevation: 0,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
  cardTheme: const CardTheme(color: Color.fromARGB(255, 57, 58, 59)),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.black,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18))),
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: const Color.fromARGB(255, 57, 58, 59),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
);

/// Light theme for Link4Launches app.
ThemeData l4lLightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Color.fromRGBO(238, 238, 238, 1),
    primary: Color.fromARGB(255, 4, 117, 162),
    onPrimary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.white,
    tertiary: Color.fromARGB(255, 151, 151, 151),
  ),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 3, 101, 140),
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(238, 238, 238, 1),
  cardTheme: const CardTheme(color: Colors.white),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color.fromARGB(255, 151, 151, 151),
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18))),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);
