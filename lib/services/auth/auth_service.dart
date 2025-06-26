import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AuthService handles authentication and user profile storage.
class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// -------------------------
  /// SIGN IN WITH EMAIL
  /// -------------------------
  ///
  /// Signs in a user using email and password.
  /// Optionally saves user info in Firestore if it doesn't exist.
  ///
  /// Throws [FirebaseAuthException] with error codes like 'user-not-found', 'wrong-password'.
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      // Attempt to sign in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optional: Save user info if not already in Firestore
      await _saveUserInfoIfNotExists(userCredential, email);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Re-throw as a simple exception with the code
      throw Exception(e.code);
    }
  }

  /// -------------------------
  /// SIGN UP WITH EMAIL
  /// -------------------------
  ///
  /// Creates a new user with email and password.
  /// Saves user info in Firestore.
  ///
  /// Throws [FirebaseAuthException] with error codes like 'email-already-in-use', 'weak-password'.
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Create a new user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save new user info to Firestore
      await _saveUserInfoIfNotExists(userCredential, email);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// -------------------------
  /// SAVE USER INFO TO FIRESTORE
  /// -------------------------
  ///
  /// Saves user details to the "Users" collection in Firestore.
  /// Only saves if the user document doesn't already exist.
  ///
  /// Fields:
  /// - uid
  /// - email
  /// - createdAt (server timestamp)
  Future<void> _saveUserInfoIfNotExists(
    UserCredential userCredential,
    String email,
  ) async {
    final user = userCredential.user;
    if (user == null) return;

    final userDoc = _firestore.collection("Users").doc(user.uid);

    // Check if the user document exists
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Create the document
      await userDoc.set({
        'uid': user.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// -------------------------
  /// SIGN OUT
  /// -------------------------
  ///
  /// Signs the current user out of Firebase.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
