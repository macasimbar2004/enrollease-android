import 'dart:async';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease/appwrite.dart';
import 'package:enrollease/dev.dart';
import 'package:enrollease/model/enrollment_form_model.dart';
import 'package:enrollease/model/user_model.dart';
import 'package:enrollease/states_management/account_data_controller.dart';
import 'package:enrollease/states_management/side_menu_index_controller.dart';
import 'package:enrollease/utils/email_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

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
      case 'invalid-credential':
        return 'Invalid credentials.';

      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<User?> logIn(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user details from Firestore based on email
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users') // Adjust the collection name as needed
          .where('email', isEqualTo: email)
          .limit(1) // Ensure we only fetch one user document
          .get();

      if (userQuerySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'No user found with the provided email.');
      }

      // Clear any previous error message
      authErrorMessage = null;
      final user = UserModel.fromMap(userQuerySnapshot.docs.first.data());
      await EmailProvider().sendLoginAlert(email: email, userName: user.userName);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      authErrorMessage = _handleAuthError(e); // Handle Firebase Auth errors
      dPrint('Error during login: ${e.message}');
      return null; // Return null to indicate failure
    }
  }

  // Method to save user data to Firestore
  Future<void> saveUserData({required String userId, required String userName, required String role, required String email, required String contactNumber, required bool isActive}) async {
    try {
      await _firestore.collection('users').doc(userId).set({'uid': userId, 'userName': userName, 'role': role, 'email': email, 'contactNumber': contactNumber, 'isActive': isActive});
      dPrint('User data saved successfully.');
    } catch (e) {
      dPrint('Error saving user data: $e');
    }
  }

  // Method to save user data to Firestore
  Future<void> saveEnrollmentFormData(EnrollmentFormModel enrollmentForm) async {
    try {
      // Save enrollment form data to Firestore with the generated ID
      await _firestore
          .collection('enrollment_forms')
          .doc(enrollmentForm.regNo) // Use the generated ID here
          .set(enrollmentForm.toMap());

      dPrint('User data saved successfully with ID: ${enrollmentForm.regNo}.');
    } catch (e) {
      dPrint('Error saving user data: $e');
    }
  }

  // Method to generate a new identification ID based on the current max ID
  Future<String> generateNewIdentification() async {
    try {
      // Fetch all document IDs from the 'users' collection
      final querySnapshot = await _firestore.collection('users').get();

      // If the collection is empty, start with the first ID (e.g., SDA24-000000)
      if (querySnapshot.docs.isEmpty) {
        return 'SDAP${DateTime.now().year % 100}-000000';
      }

      // Extract the last document ID and parse the numeric part
      final lastDoc = querySnapshot.docs.last.id;
      final yearPrefix = 'SDAP${DateTime.now().year % 100}-';

      // Check if the last ID starts with the current year prefix
      if (!lastDoc.startsWith(yearPrefix)) {
        return '${yearPrefix}000000'; // If not, return the first ID for this year
      }

      // Extract the numeric part and increment it
      final lastNumber = int.parse(lastDoc.substring(yearPrefix.length));
      final newIncrement = (lastNumber + 1).toString().padLeft(6, '0');

      // Generate the new ID
      return '$yearPrefix$newIncrement';
    } catch (e) {
      dPrint('Error generating new identification ID: $e');
      return 'SDAP${DateTime.now().year % 100}-000000'; // Fallback to first ID if error occurs
    }
  }

  // Method to generate a new identification ID based on the current max ID in 'enrollment_forms' collection
  Stream<String> generateNewEnrollmentNo() async* {
    final yearPrefix = 'SDAR${DateTime.now().year % 100}-';

    try {
      String lastGeneratedEnrollmentNo = '';

      // Listen for real-time updates from Firestore periodically (every 100ms)
      await for (var _ in Stream.periodic(const Duration(milliseconds: 100))) {
        // Fetch the latest enrollment number from Firestore once
        final querySnapshot = await _firestore.collection('enrollment_forms').get();

        // If the collection is empty, start with '000000'
        if (querySnapshot.docs.isEmpty) {
          lastGeneratedEnrollmentNo = '${yearPrefix}000000-${_getUniqueSuffix()}';
          yield lastGeneratedEnrollmentNo;
          continue;
        }

        final lastDoc = querySnapshot.docs.last.id;

        // Check if the last ID starts with the correct year prefix
        if (!lastDoc.startsWith(yearPrefix)) {
          lastGeneratedEnrollmentNo = '${yearPrefix}000000-${_getUniqueSuffix()}';
          yield lastGeneratedEnrollmentNo;
          continue;
        }

        // Extract the numeric part (the 6-digit number) from the last document ID
        final suffixStartIndex = yearPrefix.length;
        final dashIndex = lastDoc.indexOf('-', suffixStartIndex);

        // If the dash is not found, generate a new number
        if (dashIndex == -1) {
          lastGeneratedEnrollmentNo = '${yearPrefix}000000-${_getUniqueSuffix()}';
          yield lastGeneratedEnrollmentNo;
          continue;
        }

        final lastNumberString = lastDoc.substring(suffixStartIndex, dashIndex);
        final lastNumber = int.tryParse(lastNumberString) ?? 0;
        int newNumber = lastNumber + 1;

        // Ensure the new number is padded to 6 digits
        final newIncrement = newNumber.toString().padLeft(6, '0');

        // Generate the final enrollment number with unique timestamp suffix
        lastGeneratedEnrollmentNo = '$yearPrefix$newIncrement-${_getUniqueSuffix()}';

        // Emit the new registration number
        yield lastGeneratedEnrollmentNo;
      }
    } catch (e) {
      dPrint('Error generating new enrollment number: $e');
      yield '${yearPrefix}000000-${_getUniqueSuffix()}'; // Fallback ID if error occurs
    }
  }

// Helper function to get the unique microsecond or millisecond suffix
  String _getUniqueSuffix() {
    final timeSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7); // Last 6 digits of milliseconds
    return timeSuffix.padLeft(6, '0'); // Ensure 6 digits
  }

  // query for specific email of user and history logs
  Stream<List<String>> getDocId(BuildContext context, String userId) {
    // Prepare the list for the 'whereIn' filter
    final uidFilter = [''];
    if (userId.isNotEmpty) {
      uidFilter.add(userId);
    }

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('type', whereIn: ['global', 'user']) // Fetch global and user-specific notifications
        .where('uid', whereIn: uidFilter) // Filter based on userId if available
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) => doc.id).toList());
  }

  // Update isRead field for all notifications
  Future<void> markNotificationsAsRead(BuildContext context, String userId) async {
    try {
      // Get the document IDs of all relevant notifications
      final docIds = await FirebaseFirestore.instance
          .collection('notifications')
          .where('type', whereIn: ['global', 'user']) // Include global and user-specific notifications
          .where('uid', whereIn: [userId, '']) // Match user-specific or global notifications
          .orderBy('timestamp', descending: true)
          .get()
          .then((querySnapshot) => querySnapshot.docs.map((doc) => doc.id).toList());

      // Create a batch operation to update all documents
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String docId in docIds) {
        DocumentReference docRef = FirebaseFirestore.instance.collection('notifications').doc(docId);
        batch.update(docRef, {'isRead': true}); // Set isRead to true
      }

      // Commit the batch operation
      await batch.commit();
    } catch (e) {
      dPrint('Error updating notifications: $e');
    }
  }

  // Stream to fetch and listen to user data
  Stream<Map<String, dynamic>> fetchAndListenToUserData() async* {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is currently logged in');

    final ref = _firestore.collection('users').where('email', isEqualTo: user.email).limit(1).snapshots();
    await for (final querySnapshot in ref) {
      Map<String, dynamic> userData = {};
      if (querySnapshot.docs.isNotEmpty) userData = querySnapshot.docs.first.data();
      yield userData;
    }
  }

  // Log out the current user
  Future<void> logOut(BuildContext context) async {
    await _auth.signOut();

    if (context.mounted) {
      context.read<AccountDataController>().setLoggedIn(false);
      context.read<SideMenuIndexController>().setSelectedIndex(0);
    }
  }

  // Get the current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if the user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  Future<String?> recoverPass(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Uint8List?> getProfilePic(BuildContext context) async {
    final userId = context.read<AccountDataController>().currentUser!.uid;
    try {
      final bytes = await storage.getFileDownload(
        bucketId: bucketIDProfilePics,
        fileId: userId,
      );
      dPrint(userId);
      if (bytes.isEmpty) {
        return null;
      }
      return bytes;
    } catch (e) {
      dPrint(e.toString());
      return null;
    }
  }

  Future<String?> changeProfilePic(String userID, PlatformFile file) async {
    if (userID.isEmpty) throw ('User was blank!');
    final mimeType = lookupMimeType(file.path!);
    dPrint(mimeType);
    try {
      try {
        // remove previous, because appwrite doesn't allow file overwrite
        await storage.deleteFile(bucketId: bucketIDProfilePics, fileId: userID);
      } catch (e) {
        dPrint(e.toString());
      }
      final response = await storage.createFile(
        bucketId: bucketIDProfilePics, // Replace with your bucket ID
        fileId: userID,
        file: InputFile.fromBytes(
          bytes: file.bytes!,
          filename: userID,
          contentType: mimeType,
        ),
      );
      dPrint('File uploaded: ${response.$id}');
      return null;
    } catch (e) {
      dPrint('Error uploading file: $e');
      return e.toString();
    }
  }

  Future<String?> changeEmail(String uid, String email) async {
    try {
      await _auth.currentUser!.verifyBeforeUpdateEmail(email);
      await _firestore.collection('users').doc(uid).update({'email': email});
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> changePass(String uid, String pass) async {
    try {
      await _auth.currentUser!.updatePassword(pass);
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> changeContactNo(String uid, String contactNo) async {
    try {
      // TODO: do OTP later?
      // await _auth.verifyPhoneNumber(
      //   verificationCompleted: (cred) {},
      //   verificationFailed: (e) {},
      //   codeSent: (verificationID, forceSendingToken) {},
      //   codeAutoRetrievalTimeout: (verificationID) {},
      // );
      await _firestore.collection('users').doc(uid).update({'contactNumber': contactNo});
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> changeUserName(String uid, String username) async {
    try {
      await _auth.currentUser!.updateDisplayName(username);
      await _firestore.collection('users').doc(uid).update({'userName': username});
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }
}
