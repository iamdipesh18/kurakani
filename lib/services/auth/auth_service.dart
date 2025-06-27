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
}
