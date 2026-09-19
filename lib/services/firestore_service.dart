import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/donation_model.dart';
import '../models/news_model.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USER ────────────────────────────────────────────────

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      if (e.toString().contains('not-found')) {
        await _db.collection('users').doc(uid).set(data);
      } else {
        rethrow;
      }
    }
  }

  // ─── DONATION ─────────────────────────────────────────────

  Future<void> createDonation(DonationModel donation) async {
    final ref = await _db.collection('donations').add(donation.toMap());
    await ref.update({'id': ref.id});
  }

  Stream<QuerySnapshot> getUserDonations(String userId) {
    return _db
        .collection('donations')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllDonations() {
    return _db
        .collection('donations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<double> getUserTotalDonations(String uid) async {
    try {
      final snap = await _db
          .collection('donations')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .get();
      double total = 0;
      for (var d in snap.docs) {
        total += (d.data()['amount'] ?? 0.0);
      }
      return total;
    } catch (e) {
      debugPrint('Error getting user total donations: $e');
      return 0;
    }
  }

  // ─── NEWS ──────────────────────────────────────────────────

  Future<void> createNews(NewsModel news) async {
    final ref = await _db.collection('news').add(news.toMap());
    await ref.update({'id': ref.id});
    final all = await _db.collection('news').orderBy('createdAt', descending: true).get();
    if (all.docs.length > 10) {
      for (int i = 10; i < all.docs.length; i++) {
        await all.docs[i].reference.delete();
      }
    }
  }

  Stream<QuerySnapshot> getNews() {
    return _db
        .collection('news')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  Future<void> deleteNews(String id) async {
    await _db.collection('news').doc(id).delete();
  }

  // ─── ACTIVITIES ──────────────────────────────────────────

  Future<void> createActivity(ActivityModel activity) async {
    final ref = await _db.collection('activities').add(activity.toMap());
    await ref.update({'id': ref.id});
    // Keep only 20 activities
    final all = await _db
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .get();
    if (all.docs.length > 20) {
      for (int i = 20; i < all.docs.length; i++) {
        await all.docs[i].reference.delete();
      }
    }
  }

  Stream<QuerySnapshot> getActivities() {
    return _db
        .collection('activities')
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllActivities() {
    return _db
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> deleteActivity(String id) async {
    await _db.collection('activities').doc(id).delete();
  }

  Future<void> updateActivityStatus(String id, bool isPublished) async {
    await _db.collection('activities').doc(id).update({
      'isPublished': isPublished,
    });
  }

  Future<void> incrementActivityViews(String id) async {
    await _db.collection('activities').doc(id).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // ─── VOLUNTEER ────────────────────────────────────────────

  Future<void> createVolunteer(Map<String, dynamic> data) async {
    await _db.collection('volunteers').add(data);
  }

  Stream<QuerySnapshot> getVolunteers() {
    return _db
        .collection('volunteers')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateVolunteerStatus(String id, String status) async {
    await _db.collection('volunteers').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── REQUEST ──────────────────────────────────────────────

  Future<void> createRequest(Map<String, dynamic> data) async {
    final ref = await _db.collection('requests').add(data);
    await ref.update({'id': ref.id});
  }

  Stream<QuerySnapshot> getUserRequests(String uid) {
    return _db
        .collection('requests')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllRequests() {
    return _db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateRequestStatus(String id, String status) async {
    await _db.collection('requests').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── STATS ────────────────────────────────────────────────

  Future<int> getUserCount() async {
    try {
      final snap = await _db.collection('users').get();
      return snap.docs.length;
    } catch (e) {
      debugPrint('Error getting user count: $e');
      return 0;
    }
  }

  Future<double> getTotalDonations() async {
    try {
      final snap = await _db
          .collection('donations')
          .where('status', isEqualTo: 'completed')
          .get();
      double total = 0;
      for (var d in snap.docs) {
        total += (d.data()['amount'] ?? 0.0);
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total donations: $e');
      return 0;
    }
  }
}