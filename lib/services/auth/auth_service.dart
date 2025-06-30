import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles authentication and saving user data.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Sign in user
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserInfoIfNotExists(userCredential, email);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// Register new user
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserInfoIfNotExists(userCredential, email);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// Saves user info in Firestore
  Future<void> _saveUserInfoIfNotExists(
    UserCredential userCredential,
    String email,
  ) async {
    final user = userCredential.user;
    if (user == null) return;
    final userDoc = _firestore.collection("Users").doc(user.uid);
    if (!(await userDoc.get()).exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Log out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //lastmessage
  Future<String?> getLastMessage(String userId, String otherUserId) async {
    final chatId = _getChatId(userId, otherUserId);

    final snapshot = await _firestore
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['message'] as String;
    }

    return null; // no message yet
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }
}
