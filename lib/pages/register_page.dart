import 'package:flutter/material.dart';
import 'package:kurakani/components/labeled_textfield.dart';
import 'package:kurakani/components/my_button.dart';

class RegisterPage extends StatelessWidget {
  //Email and Password Controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmedPasswordController =
      TextEditingController();

  //tap to goto login page
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  //login method
  void login() {
    //method of login  with authentication
  }

  //register method
  void register() {
    //method of register with firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 50),

            //welcomeback message
            Text(
              "Lets Create an Account for You!!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            //email text field
            LabeledTextField(
              labelText: 'Email',
              hintText: 'Enter Email',
              obscureText: false,
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            //password text field
            LabeledTextField(
              labelText: 'Password',
              hintText: 'Enter Password',
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 10),
            //Confirm password text field
            LabeledTextField(
              labelText: 'Confirm Passwoord',
              hintText: 'Enter Your Password',
              obscureText: true,
              controller: _confirmedPasswordController,
            ),

            const SizedBox(height: 25),

            //Register button
            MyButton(text: 'Register', onTap: register),

            const SizedBox(height: 25),

            //Login message
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
                  onTap: onTap,
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

            // //register button
            //   MyButton(
            //   text: 'Register',
            //   onTap: register,
            //   ),
          ],
        ),
      ),
    );
  }
}
