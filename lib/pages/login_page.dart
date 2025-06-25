import 'package:flutter/material.dart';
import 'package:kurakani/components/my_button.dart';
import 'package:kurakani/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  //Email and Password Controller
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _passwordController=TextEditingController();

  LoginPage({super.key});

  //login method
  void login(){
    //method of login  with authentication
  }

  //register method
  void register(){
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

            const SizedBox(height:50),

            //welcomeback message
            Text(
              "Welcome Back, You've Been Missed!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height:50),

            //email text field
            MyTextfield(
              obscureText: false,
              hintText: "Email",
              controller:_emailController,
            ),
            const SizedBox(height:10),
            //password text field
              MyTextfield( 
                obscureText: true,
                hintText: "Password",
                controller: _passwordController,
            ),

            const SizedBox(height:25),

            //login button
            MyButton(
              text: 'Login', 
              onTap: login,
              ),

            const SizedBox(height:25),

            //register message
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a Member? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Register Now",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
