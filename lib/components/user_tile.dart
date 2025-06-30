import 'package:flutter/material.dart';

/// ✅ A reusable tile widget to display a user in the home screen chat list.
/// Shows: email, last message preview, and timestamp.
class UserTile extends StatelessWidget {
  final String text; // User's email
  final String? subtitle; // Last message preview
  final String? timestamp; // Formatted time (e.g., "3:45 PM")
  final VoidCallback? onTap; // Called when tile is tapped

  const UserTile({
    super.key,
    required this.text,
    this.subtitle,
    this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      // User's avatar based on first letter of email
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: colorScheme.primary.withOpacity(0.1),
        child: Text(
          text.isNotEmpty ? text[0].toUpperCase() : '?',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      // User email
      title: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Optional last message preview
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,

      // Optional timestamp on the right
      trailing: timestamp != null
          ? Text(
              timestamp!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            )
          : null,

      onTap: onTap,
    );
  }
}
