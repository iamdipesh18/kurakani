import 'package:flutter/material.dart';

class VisibilityToggleIcon extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onToggle;

  const VisibilityToggleIcon({
    super.key,
    required this.isObscured,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off : Icons.visibility,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: onToggle,
    );
  }
}
