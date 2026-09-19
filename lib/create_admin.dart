import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAdmin {
  static Future<void> createAdmin() async {
    try {
      // Admin credentials
      const String adminEmail = 'nawabalidirv45@gmail.com';
      const String adminPassword = 'NawabJalali@45';
      const String adminName = 'Nawab Ali';

      // Check if admin already exists
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Save admin to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': adminName,
          'email': adminEmail,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'uid': user.uid,
        });

        await user.updateDisplayName(adminName);
        print('✅ Admin created successfully!');
        print('Email: $adminEmail');
        print('Password: $adminPassword');
      }
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('ℹ️ Admin already exists');
      } else {
        print('❌ Error creating admin: $e');
      }
    }
  }
}