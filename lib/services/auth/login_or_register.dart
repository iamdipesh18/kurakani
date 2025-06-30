import 'package:flutter/material.dart';
import 'package:kurakani/pages/login_page.dart';
import 'package:kurakani/pages/register_page.dart';

/// Stateless toggle between login and register,
/// controlled from AppRoot to persist state on rebuild.
class LoginOrRegister extends StatelessWidget {
  final bool showLoginPage;
  final VoidCallback onToggle;

  const LoginOrRegister({
    super.key,
    required this.showLoginPage,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return showLoginPage
        ? LoginPage(onTap: onToggle)
        : RegisterPage(onTap: onToggle);
  }
}
