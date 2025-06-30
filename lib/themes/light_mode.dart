import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Colors.teal,
    secondary: Colors.tealAccent,
    surface: Colors.white,
    background: Colors.grey.shade100,
  ),
  scaffoldBackgroundColor: Colors.grey.shade100,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    iconTheme: IconThemeData(color: Colors.black54),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 15, color: Colors.black87),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
  // cardTheme: CardTheme(
  //   color: Colors.white,
  //   elevation: 1,
  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  // ),
);
