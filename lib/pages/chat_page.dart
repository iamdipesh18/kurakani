import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kurakani/components/chat_bubble.dart';
import 'package:kurakani/components/my_textfield.dart';
import 'package:kurakani/services/auth/auth_service.dart';
import 'package:kurakani/services/chat/chat_service.dart';

/// The private chat screen between two users.
class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId; // ✅ updated naming

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  /// Scrolls to the newest message in the list.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Sends a message and scrolls to the bottom.
  void sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId, text); // ✅ updated
      _messageController.clear();
      _scrollToBottom();
    }
  }

  /// Bottom sheet for actions like Report or Block
  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                _confirmReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                _confirmBlock();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Report confirmation dialog
  void _confirmReport() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Report User"),
        content: const Text("Are you sure you want to report this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showReportReasonDialog();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  /// Reason input for reporting
  void _showReportReasonDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reason for Reporting"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter your reason...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                await _chatService.reportUser(widget.receiverId, reason); // ✅ updated
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User has been reported")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  /// Confirmation to block a user
  void _confirmBlock() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Block User"),
        content: const Text("Are you sure you want to block this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              await _chatService.blockUser(widget.receiverId); // ✅ updated
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User has been blocked")),
              );
              Navigator.pop(context); // Go back after block
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  /// Message stream builder
  Widget _buildMessageList() {
    final currentUserId = _authService.getCurrentUser()?.uid;
    if (currentUserId == null) {
      return const Center(child: Text("Not logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(currentUserId, widget.receiverId), // ✅ updated
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) => _buildMessageItem(docs[index]),
        );
      },
    );
  }

  /// Renders each individual message bubble with safety checks
  Widget _buildMessageItem(DocumentSnapshot doc) {
    final raw = doc.data();
    if (raw == null || raw is! Map<String, dynamic>) return const SizedBox();

    final data = raw;
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return const SizedBox();

    final isMe = data['senderId'] == currentUser.uid;
    final message = data['message'] ?? '[No message]';
    final timestamp = data['timestamp'];
    final receiverId = data['receiverId'] ?? 'unknown'; // ✅ match Firestore key
    final receiverEmail = widget.receiverEmail;

    // Format time safely
    final formattedTime = timestamp is Timestamp
        ? DateFormat('h:mm a').format(timestamp.toDate())
        : '';

    return ChatBubble(
      message: message,
      isMe: isMe,
      timestamp: formattedTime,
      receiverId: receiverId,
      receiverEmail: receiverEmail,
    );
  }

  /// Text input + Send button
  Widget _buildUserInput() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              hintText: "Type a message...",
              obscureText: false,
              controller: _messageController,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.white,
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.receiverEmail),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showOptionsSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildUserInput(),
          ],
        ),
      ),
    );
  }
}
