import 'package:flutter/material.dart';
import 'package:kurakani/services/chat/chat_service.dart';
import 'package:kurakani/services/auth/auth_service.dart';

class BlockedUserPage extends StatefulWidget {
  const BlockedUserPage({super.key});

  @override
  State<BlockedUserPage> createState() => _BlockedUserPageState();
}

class _BlockedUserPageState extends State<BlockedUserPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  /// Confirm and unblock a user
  void _confirmUnblock(String blockedUserId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: const Text('Are you sure you want to unblock this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await _chatService.unblockUser(blockedUserId);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("User unblocked")));
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users'), centerTitle: true),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getBlockedUsersStreamDetailed(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final blockedUsers = snapshot.data ?? [];

          if (blockedUsers.isEmpty) {
            return const Center(
              child: Text('No blocked users', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              final userId = user['uid'];
              final userEmail = user['email'];

              return ListTile(
                leading: const Icon(Icons.person_off),
                title: Text(userEmail ?? 'Unknown'),
                trailing: TextButton(
                  onPressed: () => _confirmUnblock(userId),
                  child: const Text('Unblock'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
