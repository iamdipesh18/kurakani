import 'package:flutter/material.dart';
import 'package:kurakani/services/chat/chat_service.dart';
import 'package:kurakani/services/auth/auth_service.dart';

/// Chat bubble UI for messages
/// Displays message, timestamp, and supports long press actions for report/block
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? timestamp;
  final String receiverId; // Needed for block/report
  final String receiverEmail;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.timestamp,
    required this.receiverId,
    required this.receiverEmail,
  });

  /// Show modal bottom sheet with options: Report, Block, Cancel
  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context); // close bottom sheet
                _confirmReport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context); // close bottom sheet
                _confirmBlock(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to confirm reporting the user and ask for reason
  void _confirmReport(BuildContext context) {
    final TextEditingController _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this user?'),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your reason...',
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
              final reason = _reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context); // Close dialog
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

  /// Show dialog to confirm blocking the user
  /// On confirmation, blocks and navigates back to home
  void _confirmBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await ChatService().blockUser(receiverId);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('User blocked')));

              // Pop back to home screen after blocking
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

    // Choose colors depending on message sender
    final backgroundColor = isMe
        ? colorScheme.primary
        : colorScheme.surfaceVariant;

    final textColor = isMe
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? null : () => _showActionSheet(context),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                  padding: const EdgeInsets.only(top: 4),
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
