import 'package:flutter/material.dart';
import 'package:kurakani/components/labeled_textfield.dart';
import 'package:kurakani/components/my_button.dart';
import 'package:kurakani/services/auth/auth_service.dart';
import 'package:kurakani/components/toggle_widget_for_signin_reg.dart';

/// A modern login page UI using minimal Material 3 design.
class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Handles sign-in with Firebase and displays error on failure
  void login() async {
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;

      // Optionally show success UI or navigate
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Login Failed"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Main content (login form)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message, size: 60, color: colorScheme.primary),
                    const SizedBox(height: 40),
                    Text(
                      "Welcome Back 👋",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    LabeledTextField(
                      labelText: "Email",
                      hintText: "Enter your email",
                      obscureText: false,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      labelText: "Password",
                      hintText: "Enter your password",
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 30),
                    MyButton(text: 'Login', onTap: login),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not a member? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Register now",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔘 Theme toggle button in top-right corner
          const Positioned(top: 16, right: 16, child: ThemeToggleAuthButton()),
        ],
      ),
    );
  }
}
