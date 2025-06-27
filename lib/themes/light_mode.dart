import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  useMaterial3: true, // Enables Material You design
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.grey.shade100,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    iconTheme: IconThemeData(color: Colors.black87),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
);
