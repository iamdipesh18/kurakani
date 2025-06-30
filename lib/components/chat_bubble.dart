import 'package:flutter/material.dart';
import 'package:kurakani/services/chat/chat_service.dart';

/// A modern, minimalistic chat bubble used in the chat UI.
/// Visually distinguishes between sender (you) and receiver messages.
/// Also supports actions like report and block on long-press (for received messages).
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? timestamp;
  final String receiverId;
  final String receiverEmail;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.timestamp,
    required this.receiverId,
    required this.receiverEmail,
  });

  /// Displays a modal with actions: Report or Block the user
  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                _confirmReport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                _confirmBlock(context);
              },
            ),
            const Divider(height: 1),
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

  /// Shows a dialog asking for a reason to report a user.
  void _confirmReport(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context);
                await ChatService().reportUser(receiverId, reason);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('User reported')));
              }
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  /// Confirmation dialog to block a user. If confirmed, navigates back to the home page.
  void _confirmBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ChatService().blockUser(receiverId);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('User blocked')));
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define colors for sender and receiver bubbles
    final backgroundColor = isMe
        ? colorScheme.primary.withOpacity(0.9)
        : colorScheme.surfaceVariant;

    final textColor = isMe ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? null : () => _showActionSheet(context),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(0),
              bottomRight: isMe
                  ? const Radius.circular(0)
                  : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(message, style: TextStyle(color: textColor, fontSize: 16)),
              if (timestamp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    timestamp!,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
