import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kurakani/components/chat_bubble.dart';
import 'package:kurakani/components/my_textfield.dart';
import 'package:kurakani/services/auth/auth_service.dart';
import 'package:kurakani/services/chat/chat_service.dart';

/// Chat screen between current user and another user
class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    Key? key,
    required this.receiverEmail,
    required this.receiverID,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  /// Scroll to latest message
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

  /// Send message
  void sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  /// Shows options when a message is long-pressed
  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
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
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Step 1: Confirm before reporting
  void _confirmReport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Report User"),
          content: const Text("Are you sure you want to report this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showReportReasonDialog();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  /// Step 2: Ask for reason and report
  void _showReportReasonDialog() {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Report Reason"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: "Enter the reason for reporting",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  await _chatService.reportUser(widget.receiverID, reason);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User has been reported.")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  /// Confirm before blocking
  void _confirmBlock() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Block User"),
          content: const Text("Are you sure you want to block this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _chatService.blockUser(widget.receiverID);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User has been blocked.")),
                );
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  /// Stream of chat messages between current user and receiver
  Widget _buildMessageList() {
    final currentUserId = _authService.getCurrentUser()!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(currentUserId, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(docs[index]);
          },
        );
      },
    );
  }

  /// Each chat message bubble
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final bool isMe = data['senderId'] == _authService.getCurrentUser()!.uid;

    final Timestamp timestamp = data['timestamp'];
    final String formattedTime = DateFormat(
      'h:mm a',
    ).format(timestamp.toDate());

    return ChatBubble(
      message: data['message'],
      isMe: isMe,
      timestamp: formattedTime,
      receiverId: widget.receiverID, // 👈 Add this
      receiverEmail: widget.receiverEmail, // 👈 Add this
    );
  }

  /// Text input & send button at bottom
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
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
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
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
          elevation: 0,
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
