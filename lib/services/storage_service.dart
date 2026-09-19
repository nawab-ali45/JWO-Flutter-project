import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Store image as base64 in Firestore
  Future<String> uploadFile({
    required String path,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      // Convert to base64
      final String base64Image = base64Encode(bytes);

      // Store in Firestore
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      await _firestore.collection('users').doc(userId).set({
        'profileImageBase64': base64Image,
        'profileImageUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Return a data URI that can be displayed or emailed
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      debugPrint('Error storing image: $e');
      return '';
    }
  }

  /// Get stored image from Firestore
  Future<String?> getProfileImage(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final base64 = data['profileImageBase64'] as String?;
        if (base64 != null && base64.isNotEmpty) {
          return 'data:image/jpeg;base64,$base64';
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting image: $e');
      return null;
    }
  }
}