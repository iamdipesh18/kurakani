import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kurakani/pages/home_page.dart';
import 'package:kurakani/services/auth/login_or_register.dart';

/// AuthGate handles login state and login/register UI toggling.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool showLoginPage = true;

  void toggleAuthPage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return  HomePage();
        } else {
          return LoginOrRegister(
            showLoginPage: showLoginPage,
            onToggle: toggleAuthPage,
          );
        }
      },
    );
  }
}
