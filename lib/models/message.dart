import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single chat message.
class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });

  /// Convert message to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderID,
      'senderEmail': senderEmail,
      'receiverId': receiverID,
      'message': message,
      'timestamp': timestamp,
    };
  }

  /// Create Message object from Firestore Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderId'],
      senderEmail: map['senderEmail'],
      receiverID: map['receiverId'],
      message: map['message'],
      timestamp: map['timestamp'],
    );
  }
}
