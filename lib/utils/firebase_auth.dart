import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? authErrorMessage; // Variable to store error messages

  // Sign up using email and password
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      authErrorMessage = null; // Clear any previous error
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      authErrorMessage = _handleAuthError(e); // Set error message
      return null; // Return null to indicate failure
    }
  }

  // Error handling helper method
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Log in using email and password
  Future<User?> logIn({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      authErrorMessage = null; // Clear any previous error
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      authErrorMessage = _handleAuthError(e); // Set error message
      debugPrint("Error during login: ${e.message}");
      return null; // Return null to indicate failure
    }
  }

  // Method to save user data to Firestore
  Future<void> saveUserData({
    required String userId,
    required String userName,
    required String email,
    required String contactNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'userName': userName,
        'email': email,
        'contactNumber': contactNumber,
      });
      debugPrint("User data saved successfully.");
    } catch (e) {
      debugPrint("Error saving user data: $e");
    }
  }

  // Log out the current user
  Future<void> logOut() async {
    await _auth.signOut();
  }

  // Get the current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if the user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }
}
