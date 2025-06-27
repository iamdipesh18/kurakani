import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kurakani/components/my_drawer.dart';
import 'package:kurakani/components/user_tile.dart';
import 'package:kurakani/pages/chat_page.dart';
import 'package:kurakani/services/auth/auth_service.dart';
import 'package:kurakani/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  //chat and auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home'), centerTitle: true),
      drawer: MyDrawer(),
      body: _buildUserList(context),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading users"));
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        //data
        final users = snapshot.data!;
        return ListView(
          children: users.map<Widget>((userData) {
            return _buildUserListItem(userData, context);
          }).toList(),
        );
      },
    );
  }

  // Individual List Tile for a User
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    if (currentUser.email == userData["email"]) {
      return const SizedBox.shrink(); // Don't show yourself
    }

    return UserTile(
      text: userData["email"],
      onTap: () {
        // Navigate to chat page with selected user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"],
              receiverID: userData["uid"],
            ),
          ),
        );
      },
    );
  }
}
