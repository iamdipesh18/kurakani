import 'package:flutter/material.dart';
import 'package:kurakani/auth/auth_service.dart';
import 'package:kurakani/components/labeled_textfield.dart';
import 'package:kurakani/components/my_button.dart';

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

  void register() async {
    if (_passwordController.text != _confirmedPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) =>
            const AlertDialog(title: Text("Passwords do not match")),
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

      // Optional: Navigate or show success message
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Registration Failed"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          // For smaller screens
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 50),
              Text(
                "Let's Create an Account for You!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              LabeledTextField(
                labelText: 'Email',
                hintText: 'Enter Email',
                obscureText: false,
                controller: _emailController,
              ),
              const SizedBox(height: 10),
              LabeledTextField(
                labelText: 'Password',
                hintText: 'Enter Password',
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 10),
              LabeledTextField(
                labelText: 'Confirm Password',
                hintText: 'Re-enter Password',
                obscureText: true,
                controller: _confirmedPasswordController,
              ),
              const SizedBox(height: 25),
              MyButton(text: 'Register', onTap: register),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a Member? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login Now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
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
    );
  }
}
