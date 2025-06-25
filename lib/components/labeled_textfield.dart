import 'package:flutter/material.dart';
import 'my_textfield.dart';

class LabeledTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const LabeledTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (like: Email, Password)
        Padding(
          padding: const EdgeInsets.only(left: 25.0, bottom: 5),
          child: Text(
            labelText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),

        // TextField
        MyTextfield(
          hintText: hintText,
          obscureText: obscureText,
          controller: controller,
        ),
      ],
    );
  }
}
