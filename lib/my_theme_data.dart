import 'package:flutter/material.dart';

ThemeData myThemeData = ThemeData(
  primarySwatch: Colors.yellow,
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.yellow.shade700,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.yellow.shade700,
    selectionColor: Colors.yellow.shade200,
    selectionHandleColor: Colors.yellow.shade700,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    floatingLabelStyle: TextStyle(color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow.shade700,
      foregroundColor: Colors.white,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.yellow.shade700,
      foregroundColor: Colors.white,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
       backgroundColor: Colors.yellow.shade700,
      foregroundColor: Colors.white,
    ),
  ),
   floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.yellow.shade700,
    foregroundColor: Colors.white,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: Colors.yellow.shade700,
    thumbColor: Colors.yellow.shade700
  )
);