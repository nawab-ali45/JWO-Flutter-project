import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestore = FirestoreService();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isEditing = false;
  bool isUploadingImage = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? profileImageBase64;
  final ImagePicker _picker = ImagePicker();
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        userData = await _firestore.getUserData(user!.uid);
        if (userData != null) {
          setState(() {
            nameController.text = userData?['name'] ?? '';
            fatherNameController.text = userData?['fatherName'] ?? '';
            bloodGroupController.text = userData?['bloodGroup'] ?? '';
            phoneController.text = userData?['phone'] ?? '';
            addressController.text = userData?['address'] ?? '';
            profileImageBase64 = userData?['profileImageBase64'];
            isLoading = false;
          });
        } else {
          setState(() {
            nameController.text = user?.displayName ?? '';
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadProfileImage(XFile image) async {
    if (user == null) {
      _showSnackBar('Please login first.', Colors.red);
      return;
    }

    try {
      setState(() => isUploadingImage = true);
      final Uint8List imageBytes = await image.readAsBytes();
      final String base64String = base64Encode(imageBytes);

      await _firestore.updateUser(user!.uid, {
        'profileImageBase64': base64String,
      });

      setState(() {
        profileImageBase64 = base64String;
        isUploadingImage = false;
      });

      _showSnackBar('✅ Profile picture uploaded!', Colors.green);
      await fetchUserData();
    } catch (e) {
      setState(() => isUploadingImage = false);
      debugPrint('Upload error: $e');
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) await _uploadProfileImage(image);
  }

  Future<void> takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) await _uploadProfileImage(image);
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () { Navigator.pop(context); takePhoto(); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () { Navigator.pop(context); pickImage(); },
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty) {
      _showSnackBar('Name is required!', Colors.red);
      return;
    }
    setState(() => isLoading = true);
    try {
      await _firestore.updateUser(user!.uid, {
        'name': nameController.text,
        'fatherName': fatherNameController.text,
        'bloodGroup': bloodGroupController.text,
        'phone': phoneController.text,
        'address': addressController.text,
      });
      await user?.updateDisplayName(nameController.text);
      setState(() { isEditing = false; isLoading = false; });
      _showSnackBar('Profile updated!', Colors.green);
      await fetchUserData();
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.green)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green.shade700,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => isEditing = true),
            ),
          if (isEditing)
            TextButton(
              onPressed: saveProfile,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400]),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: showImageOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImageBase64 != null
                              ? MemoryImage(base64Decode(profileImageBase64!))
                              : null,
                          child: profileImageBase64 == null
                              ? const Icon(Icons.person, size: 60, color: Colors.green)
                              : null,
                        ),
                        if (isUploadingImage)
                          Positioned(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, size: 20, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isEditing)
                    Text(
                      userData?['name'] ?? user?.displayName ?? 'User',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  Text(
                    user?.email ?? 'No email',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (profileImageBase64 != null && !isUploadingImage)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '✅ Photo uploaded',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildField('Full Name', nameController, Icons.person, isEditing),
                      _buildField('Father\'s Name', fatherNameController, Icons.family_restroom, isEditing),
                      _buildDropdownField('Blood Group', bloodGroupController, bloodGroups, isEditing),
                      _buildField('Phone Number', phoneController, Icons.phone, isEditing, keyboardType: TextInputType.phone),
                      _buildField('Address', addressController, Icons.location_on, isEditing, maxLines: 2),
                      _buildInfoField('Email', user?.email ?? '', Icons.email),
                      _buildInfoField(
                        'Member Since',
                        userData?['createdAt'] != null
                            ? (userData!['createdAt'] as Timestamp).toDate().toString().split(' ')[0]
                            : 'Recently',
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (Helper methods _buildField, _buildDropdownField, _buildInfoField – unchanged)
  Widget _buildField(String label, TextEditingController controller, IconData icon, bool editing,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    if (editing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(icon, color: Colors.green.shade700),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      );
    }
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.green.shade700),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(controller.text.isEmpty ? 'Not provided' : controller.text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items, bool editing) {
    if (editing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.bloodtype, color: Colors.green.shade700),
          ),
          value: controller.text.isEmpty ? null : controller.text,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) => controller.text = value ?? '',
        ),
      );
    }
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(Icons.bloodtype, color: Colors.green.shade700),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(controller.text.isEmpty ? 'Not provided' : controller.text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.green.shade700),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}