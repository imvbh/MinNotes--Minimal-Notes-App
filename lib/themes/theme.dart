import 'package:flutter/material.dart';

// light mode
ThemeData lightMode = ThemeData(
  brightness: Brightness. light,
  colorScheme: ColorScheme. light (
    background: Colors.grey.shade300,
    primary: Colors.grey.shade200,
    secondary: Colors.grey.shade200,
    inversePrimary: Colors.grey.shade800,
  ), // ColorScheme. light
); // ThemeData

// dark mode
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Color.fromARGB(255, 23, 23, 23),
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ), // ColorScheme.dark
); // ThemeData