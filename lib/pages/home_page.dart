import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kurakani/components/my_drawer.dart';
import 'package:kurakani/pages/chat_page.dart';
import 'package:kurakani/services/chat/chat_service.dart';

/// ✅ HomePage displays a list of users available for chat
/// with last message preview and timestamp inside beautiful cards.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAndPromptUsername();
  }

  /// 🔎 Prompt user for username if it's missing after sign-up
  Future<void> _checkAndPromptUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection("Users").doc(user.uid).get();
    final data = userDoc.data();

    // Check if username field is missing or empty
    if (data == null ||
        !(data).containsKey("username") ||
        (data['username'] as String).isEmpty) {
      await Future.delayed(Duration.zero); // Ensure context is ready
      _showUsernameDialog(isInitialPrompt: true);
    }
  }

  /// 🧾 Show dialog to prompt user to choose or change a username
  void _showUsernameDialog({bool isInitialPrompt = false}) {
    final controller = TextEditingController();

    showDialog(
      barrierDismissible:
          !isInitialPrompt, // Don't allow dismiss on initial prompt
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isInitialPrompt ? "Choose a username" : "Change your username",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isInitialPrompt
                  ? "This will be your permanent username."
                  : "Update your username. Others will see this name.",
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          if (!isInitialPrompt)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          TextButton(
            onPressed: () async {
              final username = controller.text.trim();
              if (username.isEmpty) return;

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              // Save username to Firestore under Users collection
              final userDoc = _firestore.collection("Users").doc(user.uid);
              await userDoc.set({
                "username": username,
              }, SetOptions(merge: true));
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {}); // Refresh UI after username set
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: theme.textTheme.titleLarge?.copyWith(color: textColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: MyDrawer(
        onChangeUsernameTap: () => _showUsernameDialog(isInitialPrompt: false),
      ),
      body: _buildUserList(context),
    );
  }

  /// 🔁 Loads all users excluding those blocked by or who blocked the current user.
  Widget _buildUserList(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading users"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;
        if (users.isEmpty) {
          return const Center(
            child: Text("No users available", style: TextStyle(fontSize: 16)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final userData = users[index];
            return _buildUserCard(userData, context);
          },
        );
      },
    );
  }

  /// ✅ Builds each user card with avatar, username, last message preview and timestamp.
  Widget _buildUserCard(Map<String, dynamic> userData, BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    if (currentUser.uid == userData["uid"]) {
      return const SizedBox.shrink(); // Don't show self
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _chatService.getLastMessageWithMeta(
        currentUser.uid,
        userData['uid'],
      ),
      builder: (context, snapshot) {
        String preview = "Say hi 👋";
        String? time;

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          final message = data['message'] ?? '';
          final senderId = data['senderId'] ?? '';
          final ts = data['timestamp'];

          if (message.isNotEmpty) {
            preview = senderId == currentUser.uid ? "You: $message" : message;
          }

          if (ts != null && ts is Timestamp) {
            time = DateFormat('h:mm a').format(ts.toDate());
          }
        }

        return GestureDetector(
          onTap: () {
            // Navigate to ChatPage, passing correct argument names (receiverId, receiverEmail)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  receiverEmail: userData["email"], // user email
                  receiverId:
                      userData["uid"], // user uid - **note lowercase 'd'**
                ),
              ),
            );
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar circle with first letter of username
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      userData['username']?[0].toUpperCase() ?? '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User info column: username and last message preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['username'] ?? 'Unknown User',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preview,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Timestamp for last message, if available
                  if (time != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
