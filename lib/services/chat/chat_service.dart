import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // Instance of Firestore for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Instance of FirebaseAuth for user authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// -------------------------
  /// GET USERS STREAM
  /// -------------------------
  /// This method retrieves a real-time stream of all user documents
  /// from the "Users" collection in Firestore. It returns a list of
  /// maps where each map represents user data.
  ///
  /// Example Output:
  /// [
  ///   { 'email': 'example1@gmail.com', 'uid': 'userId1' },
  ///   { 'email': 'example2@gmail.com', 'uid': 'userId2' },
  /// ]
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data(); // Each document is already a Map<String, dynamic>
      }).toList();
    });
  }

  /// -------------------------
  /// SEND MESSAGE
  /// -------------------------
  /// This method sends a message from the current logged-in user
  /// to another user with the provided `receiverId`.
  ///
  /// It creates a chat room ID by combining the sender and receiver UIDs,
  /// then stores the message along with metadata like sender email and timestamp.
  Future<void> sendMessage(String receiverId, String message) async {
    // Get current logged-in user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email ?? 'unknown';
    final Timestamp timestamp = Timestamp.now();

    // Create a unique chat room ID based on both users
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // Ensure consistent ordering
    String chatRoomId = ids.join('_');

    // Create message document in Firestore
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'senderEmail': currentUserEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    });
  }

  // You can later implement:
  // - Stream<List<Message>> getMessages(String chatRoomId)
  // - deleteMessage()
  // - updateMessage()
}
