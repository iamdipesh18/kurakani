import 'package:flutter/material.dart';
import 'visibility_toggle_icon.dart';

/// A reusable, theme-aware text field with optional password visibility toggle.
/// Designed for minimal, modern UI with consistent padding and rounded corners.
class MyTextfield extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  /// Toggle the password visibility
  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          suffixIcon: widget.obscureText
              ? VisibilityToggleIcon(
                  isObscured: _isObscured,
                  onToggle: _toggleObscure,
                )
              : null,
        ),
      ),
    );
  }
}
