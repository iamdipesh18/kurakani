import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kurakani/pages/blocked_users_page.dart';
import 'package:kurakani/themes/theme_provider.dart';

/// App settings screen for toggling dark mode, navigating to blocked users, etc.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Dark Mode Toggle ──
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: colorScheme.primary,
            ),
            title: Text(
              'Dark Mode',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            trailing: CupertinoSwitch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),

          const Divider(height: 1),

          // ── Blocked Users ──
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(Icons.block, color: colorScheme.primary),
            title: Text(
              'Blocked Users',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlockedUserPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
