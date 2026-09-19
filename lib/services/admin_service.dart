import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Admin credentials – use environment variables in production
  static const String adminEmail = 'nawabalidirv45@gmail.com';
  static const String adminPassword = 'NawabJalali@45';
  static const String adminName = 'Nawab Ali';

  // ──────────────── CHECK ADMIN STATUS ────────────────

  /// Check if a user is an admin
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] == 'admin';
      }
      return false;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  // ──────────────── USER MANAGEMENT ────────────────

  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Update user role (admin only)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User role updated to: $role');
    } catch (e) {
      debugPrint('❌ Error updating user role: $e');
      rethrow;
    }
  }

  // ──────────────── REQUEST MANAGEMENT ────────────────

  /// Get all requests (admin only)
  Stream<QuerySnapshot> getAllRequests() {
    return _firestore
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update request status (admin only)
  Future<void> updateRequestStatus(String id, String status) async {
    try {
      await _firestore.collection('requests').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'reviewedBy': _auth.currentUser?.uid ?? 'admin',
      });
      debugPrint('✅ Request status updated to: $status');
    } catch (e) {
      debugPrint('❌ Error updating request status: $e');
      rethrow;
    }
  }

  // ──────────────── VOLUNTEER MANAGEMENT ────────────────

  /// Get all volunteers (admin only)
  Stream<QuerySnapshot> getAllVolunteers() {
    return _firestore
        .collection('volunteers')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update volunteer status (admin only)
  Future<void> updateVolunteerStatus(String id, String status) async {
    try {
      await _firestore.collection('volunteers').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'reviewedBy': _auth.currentUser?.uid ?? 'admin',
      });
      debugPrint('✅ Volunteer status updated to: $status');
    } catch (e) {
      debugPrint('❌ Error updating volunteer status: $e');
      rethrow;
    }
  }

  // ──────────────── STATISTICS ────────────────

  /// Get dashboard statistics (admin only)
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final users = await _firestore.collection('users').get();
      final donations = await _firestore.collection('donations').where('status', isEqualTo: 'completed').get();
      final pendingRequests = await _firestore.collection('requests').where('status', isEqualTo: 'pending').get();
      final pendingVolunteers = await _firestore.collection('volunteers').where('status', isEqualTo: 'pending').get();

      double totalDonationAmount = 0;
      for (var doc in donations.docs) {
        totalDonationAmount += (doc.data() as Map<String, dynamic>)['amount'] ?? 0.0;
      }

      return {
        'totalUsers': users.docs.length,
        'totalDonations': donations.docs.length,
        'totalDonationAmount': totalDonationAmount,
        'pendingRequests': pendingRequests.docs.length,
        'pendingVolunteers': pendingVolunteers.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {
        'totalUsers': 0,
        'totalDonations': 0,
        'totalDonationAmount': 0.0,
        'pendingRequests': 0,
        'pendingVolunteers': 0,
      };
    }
  }

  // ──────────────── LOGOUT ────────────────

  /// Logout admin
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('✅ Admin logged out');
    } catch (e) {
      debugPrint('❌ Error logging out: $e');
      rethrow;
    }
  }
}