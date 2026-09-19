import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firestore_service.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController bloodController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();

  String? _cvFileName;
  String? _cvBase64;
  bool _isUploading = false;

  final FirestoreService _firestore = FirestoreService();
  final List<String> bloodGroups = <String>['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  bool isLoading = false;

  Future<void> _pickCV() async {
    try {
      if (mounted) {
        setState(() => _isUploading = true);
      }

      final FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>[
          'pdf',
          'doc',
          'docx',
        ],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile file = result.files.single;

      if (file.bytes == null || file.bytes!.isEmpty) {
        if (mounted) {
          _showSnackBar(
            'Could not read the selected CV file.',
            Colors.red,
          );
        }
        return;
      }

      final String base64String = base64Encode(file.bytes!);

      if (mounted) {
        setState(() {
          _cvFileName = file.name;
          _cvBase64 = base64String;
        });

        _showSnackBar(
          '✅ CV uploaded successfully!',
          Colors.green,
        );
      }
    } catch (e) {
      debugPrint('Error picking CV: $e');

      if (mounted) {
        _showSnackBar(
          'Error selecting CV: $e',
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<bool> _checkUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please login first', Colors.red);
      return false;
    }

    final userData = await _firestore.getUserData(user.uid);
    if (userData == null) {
      _showSnackBar('⚠️ Please complete your profile first', Colors.orange);
      return false;
    }

    final name = userData['name'] ?? '';
    final fatherName = userData['fatherName'] ?? '';
    final phone = userData['phone'] ?? '';
    final address = userData['address'] ?? '';
    final bloodGroup = userData['bloodGroup'] ?? '';

    if (name.isEmpty || fatherName.isEmpty || phone.isEmpty ||
        address.isEmpty || bloodGroup.isEmpty) {
      _showSnackBar('⚠️ Please complete your profile first (Name, Father Name, Phone, Address, Blood Group)', Colors.orange);
      return false;
    }

    return true;
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 3)),
    );
  }

  Future<void> apply() async {
    final hasProfile = await _checkUserProfile();
    if (!hasProfile) return;

    if (nameController.text.isEmpty || fatherController.text.isEmpty ||
        phoneController.text.isEmpty || cnicController.text.isEmpty) {
      _showSnackBar("Please fill all required fields", Colors.red);
      return;
    }

    if (mounted) setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser!;
    final userEmail = user.email ?? '';

    final Map<String, dynamic> data = <String, dynamic>{
      "name": nameController.text,
      "fatherName": fatherController.text,
      "bloodGroup": bloodController.text.isNotEmpty ? bloodController.text : null,
      "phone": phoneController.text,
      "address": addressController.text.isNotEmpty ? addressController.text : null,
      "cnic": cnicController.text,
      "position": positionController.text.isNotEmpty ? positionController.text : 'Volunteer',
      "skills": skillsController.text.isNotEmpty ? skillsController.text : null,
      "experience": experienceController.text.isNotEmpty ? experienceController.text : null,
      "availability": availabilityController.text.isNotEmpty ? availabilityController.text : null,
      "cvFileName": _cvFileName,
      "cvBase64": _cvBase64,
      "userId": user.uid,
      "status": "pending",
      "email": userEmail,
      "createdAt": FieldValue.serverTimestamp(),
    };

    await _firestore.createVolunteer(data);

    if (mounted) {
      setState(() => isLoading = false);
      _showSnackBar("✅ Application submitted!", Colors.green);
    }

    nameController.clear();
    fatherController.clear();
    phoneController.clear();
    addressController.clear();
    cnicController.clear();
    positionController.clear();
    skillsController.clear();
    experienceController.clear();
    availabilityController.clear();
    bloodController.clear();
    setState(() {
      _cvFileName = null;
      _cvBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Changed from 4 to 3 - Removed Committee tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Volunteers"),
          backgroundColor: Colors.green.shade700,
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: "Apply", icon: Icon(Icons.person_add)),
              Tab(text: "List", icon: Icon(Icons.people)),
              Tab(text: "Status", icon: Icon(Icons.assignment)),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _ApplyTab(),
            _ListTab(),
            _StatusTab(),
          ],
        ),
      ),
    );
  }
}

// ==================== APPLY TAB ====================
class _ApplyTab extends StatefulWidget {
  const _ApplyTab();

  @override
  State<_ApplyTab> createState() => _ApplyTabState();
}

class _ApplyTabState extends State<_ApplyTab> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController bloodController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();

  String? _cvFileName;
  String? _cvBase64;
  bool _isUploading = false;
  bool isLoading = false;

  final FirestoreService _firestore = FirestoreService();
  final List<String> bloodGroups = <String>['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<void> _pickCV() async {
    try {
      if (mounted) setState(() => _isUploading = true);
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf', 'doc', 'docx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final PlatformFile file = result.files.single;
      if (file.bytes == null || file.bytes!.isEmpty) {
        if (mounted) _showSnackBar('Could not read the selected CV file.', Colors.red);
        return;
      }
      final String base64String = base64Encode(file.bytes!);
      if (mounted) {
        setState(() {
          _cvFileName = file.name;
          _cvBase64 = base64String;
        });
        _showSnackBar('✅ CV uploaded successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error selecting CV: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<bool> _checkUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please login first', Colors.red);
      return false;
    }
    final userData = await _firestore.getUserData(user.uid);
    if (userData == null) {
      _showSnackBar('⚠️ Please complete your profile first', Colors.orange);
      return false;
    }
    final name = userData['name'] ?? '';
    final fatherName = userData['fatherName'] ?? '';
    final phone = userData['phone'] ?? '';
    final address = userData['address'] ?? '';
    final bloodGroup = userData['bloodGroup'] ?? '';
    if (name.isEmpty || fatherName.isEmpty || phone.isEmpty ||
        address.isEmpty || bloodGroup.isEmpty) {
      _showSnackBar('⚠️ Please complete your profile first', Colors.orange);
      return false;
    }
    return true;
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 3)),
    );
  }

  Future<void> apply() async {
    final hasProfile = await _checkUserProfile();
    if (!hasProfile) return;
    if (nameController.text.isEmpty || fatherController.text.isEmpty ||
        phoneController.text.isEmpty || cnicController.text.isEmpty) {
      _showSnackBar("Please fill all required fields", Colors.red);
      return;
    }
    if (mounted) setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    final userEmail = user.email ?? '';
    final Map<String, dynamic> data = <String, dynamic>{
      "name": nameController.text,
      "fatherName": fatherController.text,
      "bloodGroup": bloodController.text.isNotEmpty ? bloodController.text : null,
      "phone": phoneController.text,
      "address": addressController.text.isNotEmpty ? addressController.text : null,
      "cnic": cnicController.text,
      "position": positionController.text.isNotEmpty ? positionController.text : 'Volunteer',
      "skills": skillsController.text.isNotEmpty ? skillsController.text : null,
      "experience": experienceController.text.isNotEmpty ? experienceController.text : null,
      "availability": availabilityController.text.isNotEmpty ? availabilityController.text : null,
      "cvFileName": _cvFileName,
      "cvBase64": _cvBase64,
      "userId": user.uid,
      "status": "pending",
      "email": userEmail,
      "createdAt": FieldValue.serverTimestamp(),
    };
    await _firestore.createVolunteer(data);
    if (mounted) {
      setState(() => isLoading = false);
      _showSnackBar("✅ Application submitted!", Colors.green);
    }
    nameController.clear();
    fatherController.clear();
    phoneController.clear();
    addressController.clear();
    cnicController.clear();
    positionController.clear();
    skillsController.clear();
    experienceController.clear();
    availabilityController.clear();
    bloodController.clear();
    setState(() {
      _cvFileName = null;
      _cvBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          const Icon(Icons.people, size: 60, color: Colors.orange),
          const SizedBox(height: 10),
          const Text("Join as a Volunteer", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Full Name *",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: fatherController,
            decoration: InputDecoration(
              labelText: "Father's Name *",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.family_restroom, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Blood Group",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.bloodtype, color: Colors.green.shade700),
            ),
            items: bloodGroups.map<DropdownMenuItem<String>>((String g) => DropdownMenuItem<String>(
              value: g,
              child: Text(g),
            )).toList(),
            onChanged: (String? v) => bloodController.text = v!,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: "Phone Number *",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.phone, color: Colors.green.shade700),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: "Address *",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.location_on, color: Colors.green.shade700),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cnicController,
            decoration: InputDecoration(
              labelText: "CNIC Number *",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.badge, color: Colors.green.shade700),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: positionController,
            decoration: InputDecoration(
              labelText: "Position (e.g., Volunteer, Coordinator)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.work, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: skillsController,
            decoration: InputDecoration(
              labelText: "Skills/Expertise",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.build, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: experienceController,
            decoration: InputDecoration(
              labelText: "Experience",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.work_history, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: availabilityController,
            decoration: InputDecoration(
              labelText: "Availability (Days/Hours)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.schedule, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('📄 Upload CV/Resume', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _isUploading ? null : _pickCV,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.upload_file, color: _cvFileName != null ? Colors.green : Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _cvFileName != null ? '📄 $_cvFileName' : 'Upload CV/Resume (PDF, DOC)',
                            style: TextStyle(
                              color: _cvFileName != null ? Colors.green : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        if (_isUploading)
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        if (_cvFileName != null && !_isUploading)
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() {
                                _cvFileName = null;
                                _cvBase64 = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (isLoading || _isUploading) ? null : apply,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("Submit Application", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

// ==================== LIST TAB ====================
class _ListTab extends StatelessWidget {
  const _ListTab();

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestore = FirestoreService();
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.getVolunteers(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.people_outline, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text('No volunteers yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text('Be the first to apply!', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        }
        final List<QueryDocumentSnapshot> volunteers = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: volunteers.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> data = volunteers[index].data() as Map<String, dynamic>;
            Color statusColor;
            Icon statusIcon;
            switch (data['status']) {
              case 'approved':
                statusColor = Colors.green;
                statusIcon = const Icon(Icons.check, color: Colors.white, size: 20);
                break;
              case 'rejected':
                statusColor = Colors.red;
                statusIcon = const Icon(Icons.close, color: Colors.white, size: 20);
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = const Icon(Icons.pending, color: Colors.white, size: 20);
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor,
                  child: statusIcon,
                ),
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('📱 ${data['phone'] ?? 'N/A'}'),
                    Text('🩸 ${data['bloodGroup'] ?? 'N/A'}'),
                    if (data['cvFileName'] != null)
                      Text('📄 ${data['cvFileName']}', style: TextStyle(fontSize: 11, color: Colors.green)),
                  ],
                ),
                onTap: () => _showVolunteerDetails(context, data),
              ),
            );
          },
        );
      },
    );
  }

  void _showVolunteerDetails(BuildContext context, Map<String, dynamic> volunteer) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(volunteer['name'] ?? 'Volunteer'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _detailTile('Father\'s Name', volunteer['fatherName']),
              _detailTile('Phone', volunteer['phone']),
              _detailTile('Blood Group', volunteer['bloodGroup']),
              _detailTile('CNIC', volunteer['cnic']),
              _detailTile('Address', volunteer['address']),
              _detailTile('Position', volunteer['position'] ?? 'Volunteer'),
              _detailTile('Skills', volunteer['skills']),
              _detailTile('Experience', volunteer['experience']),
              _detailTile('Availability', volunteer['availability']),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.file_present, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '📄 ${volunteer['cvFileName'] ?? 'No CV uploaded'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _detailTile('Status', volunteer['status']?.toString().toUpperCase() ?? 'PENDING'),
              _detailTile(
                'Submitted',
                (volunteer['createdAt'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? 'N/A',
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}

// ==================== STATUS TAB ====================
class _StatusTab extends StatelessWidget {
  const _StatusTab();

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestore = FirestoreService();
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.getVolunteers(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<QueryDocumentSnapshot> volunteers = snapshot.data!.docs;
        final int pending = volunteers.where((v) => (v.data() as Map<String, dynamic>)['status'] == 'pending').length;
        final int approved = volunteers.where((v) => (v.data() as Map<String, dynamic>)['status'] == 'approved').length;
        final int rejected = volunteers.where((v) => (v.data() as Map<String, dynamic>)['status'] == 'rejected').length;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  _buildStatusCard('🟡 Pending', pending, Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatusCard('🟢 Approved', approved, Colors.green),
                  const SizedBox(width: 12),
                  _buildStatusCard('🔴 Rejected', rejected, Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: volunteers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> data = volunteers[index].data() as Map<String, dynamic>;
                    Color statusColor;
                    switch (data['status']) {
                      case 'approved':
                        statusColor = Colors.green;
                        break;
                      case 'rejected':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.orange;
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor,
                        child: data['status'] == 'approved'
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : data['status'] == 'rejected'
                            ? const Icon(Icons.close, color: Colors.white, size: 20)
                            : const Icon(Icons.pending, color: Colors.white, size: 20),
                      ),
                      title: Text(data['name'] ?? 'Unknown'),
                      subtitle: Text('📱 ${data['phone'] ?? 'N/A'}'),
                      trailing: Text(
                        data['status']?.toString().toUpperCase() ?? 'PENDING',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: <Widget>[
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}