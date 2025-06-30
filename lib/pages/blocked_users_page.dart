import 'package:flutter/material.dart';
import 'package:kurakani/services/chat/chat_service.dart';
import 'package:kurakani/services/auth/auth_service.dart';

/// A page showing all users blocked by the current user.
class BlockedUserPage extends StatefulWidget {
  const BlockedUserPage({super.key});

  @override
  State<BlockedUserPage> createState() => _BlockedUserPageState();
}

class _BlockedUserPageState extends State<BlockedUserPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  /// Confirm and unblock a user
  void _confirmUnblock(String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unblock User'),
        content: const Text('Are you sure you want to unblock this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await _chatService.unblockUser(userId);
              Navigator.pop(context);
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

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text("You haven't blocked anyone."));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: Text(user['email'] ?? 'Unknown'),
                trailing: TextButton(
                  onPressed: () => _confirmUnblock(user['uid']),
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
