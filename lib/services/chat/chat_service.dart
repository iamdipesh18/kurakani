import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kurakani/models/message.dart';

/// ✅ ChatService handles all chat-related logic including:
/// - Sending & receiving messages
/// - Generating consistent chat IDs
/// - Blocking/unblocking/reporting users
/// - Fetching users and last message previews
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Generates a consistent chat ID based on two user IDs
  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) <= 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  /// ✅ Fetches the latest message between two users
  /// Includes message text, sender ID, and timestamp
  Future<Map<String, dynamic>?> getLastMessageWithMeta(
    String currentUserId,
    String otherUserId,
  ) async {
    final chatId = _getChatId(currentUserId, otherUserId);

    final snapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      print("📭 No messages found between $currentUserId and $otherUserId");
      return null;
    }

    final doc = snapshot.docs.first.data();
    print("📨 Last message between $currentUserId and $otherUserId: $doc");

    return {
      'message': doc['message'] ?? '',
      'senderId': doc['senderId'] ?? '',
      'timestamp': doc['timestamp'],
    };
  }

  /// 🔁 Get stream of all users in Firestore "Users" collection
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// 🔁 Get stream of users excluding those blocked by current user
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    final blockedRef = _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('blocked_users');

    return blockedRef.snapshots().asyncMap((blockedSnapshot) async {
      final blockedIds = blockedSnapshot.docs.map((doc) => doc.id).toSet();
      final allUsersSnapshot = await _firestore.collection("Users").get();

      return allUsersSnapshot.docs
          .where((doc) => doc.id != user.uid && !blockedIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  /// ✅ Sends a message using a consistent chat room ID format
  Future<void> sendMessage(String receiverId, String messageText) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final senderId = user.uid;
    final senderEmail = user.email ?? 'no-email';
    final timestamp = Timestamp.now();
    final chatRoomId = _getChatId(senderId, receiverId);

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

  /// 🔁 Returns message stream for a given chat
  Stream<QuerySnapshot> getMessages(String uid1, String uid2) {
    final chatRoomId = _getChatId(uid1, uid2);
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// ✅ Block a user by saving their ID to current user's blocked list
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

  /// ✅ Unblock a user
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

  /// 🔁 Stream of blocked user IDs
  Stream<List<String>> getBlockedUsersStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("Users")
        .doc(user.uid)
        .collection("blocked_users")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// ✅ Report a user by saving a report document
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

  /// 🔁 Stream of detailed blocked user info
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
          final doc = await _firestore.collection("Users").doc(id).get();
          if (doc.exists) {
            return {"uid": doc.id, "email": doc['email'] ?? 'Unknown'};
          }
          return <String, dynamic>{};
        }),
      );

      return blockedUsers.where((u) => u.isNotEmpty).toList();
    });
  }
}
