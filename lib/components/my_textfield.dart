import 'package:flutter/material.dart';
import 'visibility_toggle_icon.dart'; // Import the toggle icon widget

/// Custom TextField widget that supports optional password visibility toggle
/// and is styled for iOS-inspired UI.
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

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
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
