import 'package:flutter/material.dart';

ThemeData myThemeData = ThemeData(
  colorSchemeSeed: Colors.green,
  brightness: Brightness.light,
  fontFamily: "Quicksand",
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      iconColor: Colors.white
    ),
  ),
   floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
  ),
  
  useMaterial3: true,
);