import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kurakani/themes/theme_provider.dart';

/// A custom icon-based toggle widget to switch between dark and light mode.
/// Designed for auth screens (login/register) with minimal, aesthetic styling.
class ThemeToggleAuthButton extends StatelessWidget {
  const ThemeToggleAuthButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () => themeProvider.toggleTheme(),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          key: ValueKey<bool>(isDark),
          color: colorScheme.primary,
          size: 28,
        ),
      ),
    );
  }
}
