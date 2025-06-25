import 'package:flutter/material.dart';
import 'package:kurakani/auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logout() {
    //get the auth service
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        actions: [
          //logout button
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      drawer: Drawer(),
    );
  }
}
