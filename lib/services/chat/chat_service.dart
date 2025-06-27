import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kurakani/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get stream of all users in Firestore "Users" collection
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Get all users excluding those blocked by the current user
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    final blockedUsersRef = _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('blocked_users');

    return blockedUsersRef.snapshots().asyncMap((blockedSnapshot) async {
      final blockedIds = blockedSnapshot.docs.map((doc) => doc.id).toSet();

      final allUsersSnapshot = await _firestore.collection("Users").get();

      return allUsersSnapshot.docs
          .where((doc) => doc.id != user.uid && !blockedIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  /// Send a message from the current user to another user
  Future<void> sendMessage(String receiverId, String messageText) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String senderId = user.uid;
    final String senderEmail = user.email ?? 'no-email';
    final Timestamp timestamp = Timestamp.now();

    final chatRoomId = _generateChatRoomId(senderId, receiverId);

    final message = Message(
      senderID: senderId,
      senderEmail: senderEmail,
      receiverID: receiverId,
      message: messageText,
      timestamp: timestamp,
    );

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());
  }

  /// Get message stream for a chat between two users
  Stream<QuerySnapshot> getMessages(String uid1, String uid2) {
    final chatRoomId = _generateChatRoomId(uid1, uid2);
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Block a user (adds receiverId to current user's blocked list)
  Future<void> blockUser(String receiverId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection("Users")
        .doc(user.uid)
        .collection("blocked_users")
        .doc(receiverId)
        .set({"blockedAt": Timestamp.now()});
  }

  /// Unblock a user (removes from current user's blocked list)
  Future<void> unblockUser(String receiverId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection("Users")
        .doc(user.uid)
        .collection("blocked_users")
        .doc(receiverId)
        .delete();
  }

  /// Get stream of blocked users for the current user
  Stream<List<String>> getBlockedUsersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("Users")
        .doc(user.uid)
        .collection("blocked_users")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Report a user (creates a report document in a separate collection)
  Future<void> reportUser(String reportedUserId, String reason) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection("reports").add({
      "reporterId": user.uid,
      "reportedUserId": reportedUserId,
      "reason": reason,
      "timestamp": Timestamp.now(),
    });
  }

  /// Generate a unique chat room ID based on both user IDs
  String _generateChatRoomId(String id1, String id2) {
    final ids = [id1, id2];
    ids.sort(); // ensures the same order every time
    return ids.join("_");
  }

  /// Get detailed data of blocked users (email, etc.)
  Stream<List<Map<String, dynamic>>> getBlockedUsersStreamDetailed(
    String currentUserId,
  ) {
    final blockedRef = _firestore
        .collection("Users")
        .doc(currentUserId)
        .collection("blocked_users");

    return blockedRef.snapshots().asyncMap((blockedSnapshot) async {
      final blockedIds = blockedSnapshot.docs.map((doc) => doc.id).toList();

      if (blockedIds.isEmpty) return [];

      final blockedUsers = await Future.wait(
        blockedIds.map((id) async {
          final userDoc = await _firestore.collection("Users").doc(id).get();
          if (userDoc.exists) {
            return <String, dynamic>{
              "uid": userDoc.id,
              "email": userDoc['email'] ?? 'Unknown',
            };
          }
          return <String, dynamic>{};
        }),
      );

      return blockedUsers
          .where((user) => user.isNotEmpty)
          .map((user) => Map<String, dynamic>.from(user))
          .toList();
    });
  }
}
