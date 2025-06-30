import 'package:flutter/material.dart';
import 'package:kurakani/components/labeled_textfield.dart';
import 'package:kurakani/components/my_button.dart';
import 'package:kurakani/services/auth/auth_service.dart';
import 'package:kurakani/components/toggle_widget_for_signin_reg.dart'; // <-- don't forget this import

/// Registration page UI using a minimal and user-friendly form
class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmedPasswordController =
      TextEditingController();

  /// Sign up method using AuthService. Shows error if anything fails.
  void register() async {
    if (_passwordController.text != _confirmedPasswordController.text) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Password Mismatch"),
          content: Text("Passwords do not match."),
        ),
      );
      return;
    }

    try {
      final auth = AuthService();
      await auth.signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;

      // Optional: Navigate or show welcome screen
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registration Failed"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Inside your build method
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Main registration UI
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Create a New Account",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 30),
                    LabeledTextField(
                      labelText: 'Email',
                      hintText: 'Enter email',
                      obscureText: false,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      labelText: 'Password',
                      hintText: 'Enter password',
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter password',
                      obscureText: true,
                      controller: _confirmedPasswordController,
                    ),
                    const SizedBox(height: 30),
                    MyButton(text: 'Register', onTap: register),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already a member? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Login now",
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

          // 🔘 Top-right theme toggle button
          const Positioned(top: 16, right: 16, child: ThemeToggleAuthButton()),
        ],
      ),
    );
  }
}
