import 'package:flutter/material.dart';
import 'package:kurakani/services/auth/auth_service.dart';
import 'package:kurakani/pages/settings_page.dart';

/// A custom app drawer used in the app for quick navigation and logout.
class MyDrawer extends StatelessWidget {
  /// Callback triggered when user taps "Change Username"
  final VoidCallback? onChangeUsernameTap;

  const MyDrawer({super.key, this.onChangeUsernameTap});

  /// Sign out using the AuthService
  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  /// Show a snackbar confirmation for username update
  static void showUsernameUpdateConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Username updated successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Logo + Navigation ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.message_rounded,
                    color: colorScheme.primary,
                    size: 48,
                  ),
                ),
              ),

              // Home
              ListTile(
                leading: Icon(Icons.home, color: colorScheme.primary),
                title: Text(
                  'Home',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close drawer only
                },
              ),

              // Settings
              ListTile(
                leading: Icon(Icons.settings, color: colorScheme.primary),
                title: Text(
                  'Settings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),

              // Change Username
              ListTile(
                leading: Icon(Icons.edit, color: colorScheme.primary),
                title: Text(
                  'Change Username',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (onChangeUsernameTap != null) {
                    onChangeUsernameTap!();
                    // Show confirmation AFTER username change logic completes
                    Future.delayed(const Duration(milliseconds: 500), () {
                      showUsernameUpdateConfirmation(context);
                    });
                  }
                },
              ),
            ],
          ),

          // ── Logout (Bottom-aligned) ──
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                'Logout',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}
