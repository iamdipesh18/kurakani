import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kurakani/pages/home_page.dart'; // ✅ Ensure this is correct
import 'package:kurakani/services/auth/login_or_register.dart';

/// AuthGate redirects users based on login state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomePage(); // ✅ Now this should work
        } else {
          return const LoginOrRegister();
        }
      },
    );
  }
}
