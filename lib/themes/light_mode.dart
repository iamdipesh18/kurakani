import 'package:flutter/material.dart';

/// A modern light theme using Material 3 guidelines
final ThemeData lightMode = ThemeData(
  useMaterial3: true, // Enables Material You features

  /// Automatically generates a full color scheme based on a single seed color
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.grey.shade500, // Primary tone of your app
    brightness: Brightness.light, // Indicates it's a light theme
  ),

  /// Optional: Explicitly set scaffold background (can override surface)
  scaffoldBackgroundColor: Colors.grey.shade200,

  /// Optional: Customize typography or components if needed
  // textTheme: Typography.material2021().black,
);
