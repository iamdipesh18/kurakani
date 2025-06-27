import 'package:flutter/material.dart';
import 'package:kurakani/themes/light_mode.dart';
import 'package:kurakani/themes/dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // Private variable to track theme
  ThemeData _themeData = lightMode;

  // Getter to expose the current theme
  ThemeData get themeData => _themeData;

  // Toggles between light and dark modes
  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners(); // Notify listeners to rebuild UI
  }

  // Optional: allow setting theme externally
  set themeData(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  // Whether current theme is dark
  bool get isDarkMode => _themeData == darkMode;
}
