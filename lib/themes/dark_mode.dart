import 'package:flutter/material.dart';

final ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.deepPurple,
    secondary: Colors.deepPurpleAccent,
    surface: const Color(0xFF1E1E1E),
    background: const Color(0xFF121212),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white70),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 15, color: Colors.white70),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1F1F1F),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
  // cardTheme: CardTheme(
  //   color: const Color(0xFF1E1E1E),
  //   elevation: 2,
  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  // ),
);
