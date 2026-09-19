import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Signup with Firebase email verification link
  Future<Map<String, dynamic>> signupWithEmailVerification({
    required String name,
    required String fatherName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Check if username is already taken
      final usernameSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (usernameSnapshot.docs.isNotEmpty) {
        return {'success': false, 'message': 'Username already taken'};
      }

      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // ✅ Send Firebase verification email
        await user.sendEmailVerification();

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'fatherName': fatherName,
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': user.uid,
          'role': 'user',
          'emailVerified': false,
          'isEmailVerified': false,
          'phone': '',
          'bloodGroup': '',
          'address': '',
          'profileImageBase64': '',
        });

        // Sign out so user must verify email before login
        await _auth.signOut();

        return {
          'success': true,
          'message': 'Account created! Please check your email and click the verification link to activate your account.',
        };
      }

      return {'success': false, 'message': 'Failed to create account'};
    } on FirebaseAuthException catch (e) {
      debugPrint('Signup error: $e');
      if (e.code == 'email-already-in-use') {
        return {'success': false, 'message': 'This email is already registered'};
      }
      return {'success': false, 'message': e.message ?? 'Signup failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ✅ Check if email is verified (call this after user clicks verification link)
  Future<Map<String, dynamic>> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      // Reload user to get latest verification status from Firebase
      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return {'success': false, 'message': 'User not found'};
      }

      final bool isVerified = refreshedUser.emailVerified;

      if (isVerified) {
        // ✅ Update Firestore document
        await _firestore.collection('users').doc(refreshedUser.uid).update({
          'emailVerified': true,
          'isEmailVerified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        return {
          'success': true,
          'verified': true,
          'message': 'Email verified successfully! You can now login.',
        };
      } else {
        return {
          'success': true,
          'verified': false,
          'message': 'Email not verified yet. Please check your inbox and click the verification link.',
        };
      }
    } catch (e) {
      debugPrint('Check verification error: $e');
      return {
        'success': false,
        'verified': false,
        'message': 'Failed to check verification status: $e',
      };
    }
  }

  // ✅ Login with email/username, check verification
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      String email = identifier;

      if (!identifier.contains('@')) {
        final snapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: identifier)
            .get();
        if (snapshot.docs.isEmpty) {
          return {'success': false, 'message': 'Invalid username'};
        }
        email = snapshot.docs.first.data()['email'] as String;
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        return {'success': false, 'message': 'Login failed'};
      }

      // ✅ Check if email is verified
      if (!user.emailVerified) {
        // Send a new verification email
        await user.sendEmailVerification();
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Please verify your email first. A new verification link has been sent.',
        };
      }

      // ✅ Update Firestore verification status
      await _firestore.collection('users').doc(user.uid).update({
        'emailVerified': true,
        'isEmailVerified': true,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'user': user,
        'message': 'Login successful!',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: $e');
      if (e.code == 'user-not-found') {
        return {'success': false, 'message': 'User not found'};
      } else if (e.code == 'wrong-password') {
        return {'success': false, 'message': 'Incorrect password'};
      }
      return {'success': false, 'message': e.message ?? 'Login failed'};
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'message': 'Invalid email/username or password'};
    }
  }

  // ✅ Resend verification email
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      if (user.emailVerified) {
        return {'success': false, 'message': 'Email already verified'};
      }

      await user.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email resent. Please check your inbox.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to resend verification email: $e'};
    }
  }

  // ✅ Simple reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Get user data error: $e');
      return null;
    }
  }
}