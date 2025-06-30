import 'package:flutter/material.dart';
import 'package:kurakani/services/chat/chat_service.dart';

/// A modern, minimalistic chat bubble used in the chat UI.
/// Visually distinguishes between sender (you) and receiver messages.
/// Also supports actions like Report and Block on long-press (for received messages).
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

  /// Shows a bottom sheet with options to Report or Block the user.
  /// Uses [rootContext] to ensure dialogs open on a valid context.
  void _showActionSheet(BuildContext rootContext) {
    showModalBottomSheet(
      context: rootContext,
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
                // Close the bottom sheet first
                Navigator.pop(context);

                // Use microtask to delay showing the report dialog until
                // after the bottom sheet is fully closed to avoid context errors.
                Future.microtask(() => _confirmReport(rootContext));
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                Future.microtask(() => _confirmBlock(rootContext));
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

  /// Displays a dialog asking the user to provide a reason for reporting.
  /// If the reason is provided, calls the ChatService to report the user.
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
            onPressed: () {
              Navigator.pop(context); // Close the dialog without action
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context); // Close the dialog before calling async code
                await ChatService().reportUser(receiverId, reason);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User reported')),
                );
              }
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog to block the user.
  /// If confirmed, calls ChatService to block the user and navigates back to home.
  void _confirmBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog without blocking
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog before async call
              await ChatService().blockUser(receiverId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User blocked')),
              );
              // Navigate back to the first route (home)
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

    // Background color depends on whether the message is from the current user
    final backgroundColor = isMe
        ? colorScheme.primary.withOpacity(0.9)
        : colorScheme.surfaceVariant;

    // Text color depends on sender
    final textColor = isMe ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        // Only allow long-press for received messages to show action sheet
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
              // Bottom corners depend on sender to create "speech bubble" effect
              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
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
