import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../../services/firestore_service.dart';
import '../../services/emailjs_service.dart';
import '../login.dart';

class AdminVolunteers extends StatefulWidget {
  const AdminVolunteers({super.key});

  @override
  State<AdminVolunteers> createState() => _AdminVolunteersState();
}

class _AdminVolunteersState extends State<AdminVolunteers> {
  final FirestoreService _firestore = FirestoreService();
  String filterStatus = 'All';

  List<QueryDocumentSnapshot> _volunteers = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  final Map<String, Color> statusColors = {
    'pending': Colors.orange,
    'approved': Colors.green,
    'rejected': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          _hasMore &&
          !_isLoadingMore) {
        _fetchVolunteers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchVolunteers({bool refresh = false}) async {
    if (refresh) {
      _volunteers.clear();
      _lastDocument = null;
      _hasMore = true;
      setState(() => _isLoading = true);
    }

    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('volunteers')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (filterStatus != 'All') {
        query = query.where('status', isEqualTo: filterStatus);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _volunteers.addAll(snapshot.docs);
          _lastDocument = snapshot.docs.last;
          _hasMore = snapshot.docs.length == _pageSize;
        });
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error fetching volunteers: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _downloadCV(String base64String, String fileName) async {
    try {
      final bytes = base64Decode(base64String);

      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CV downloaded!'), backgroundColor: Colors.green),
          );
        }
      } else {
        await Gal.putImageBytes(bytes, album: 'JWO');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CV saved to gallery!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading CV: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String generateVolunteerId() {
    final year = DateTime.now().year;
    final random = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toStringAsFixed(0);
    return 'JWO-V-$year-$random';
  }

  String formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<Map<String, String?>> _getUserProfileImage(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return {
          'profileImageBase64': data['profileImageBase64'] as String?,
          'profileImageUrl': data['profileImageUrl'] as String?,
        };
      }
    } catch (e) {
      debugPrint('Error fetching user profile image: $e');
    }
    return {'profileImageBase64': null, 'profileImageUrl': null};
  }

  Future<Map<String, String?>> _getUserExtraFields(Map<String, dynamic> volunteerData) async {
    String? cnic = volunteerData['cnic'];
    String? phone = volunteerData['phone'];

    if ((cnic == null || cnic.isEmpty) || (phone == null || phone.isEmpty)) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(volunteerData['userId'])
            .get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (cnic == null || cnic.isEmpty) cnic = data['cnic'] as String?;
          if (phone == null || phone.isEmpty) phone = data['phone'] as String?;
        }
      } catch (e) {
        debugPrint('Error fetching user fields: $e');
      }
    }
    return {'cnic': cnic, 'phone': phone};
  }

  // ✅ Volunteer Card Email - Only EmailJS
  Future<bool> _sendVolunteerEmail({
    required String toEmail,
    required String name,
    required String volunteerId,
    required String fatherName,
    required String bloodGroup,
    required String position,
    required String issueDate,
    required String expiryDate,
  }) async {
    if (toEmail.isEmpty) return false;

    try {
      final emailjs = EmailJSService();
      final result = await emailjs.sendVolunteerCard(
        toEmail: toEmail,
        name: name,
        volunteerId: volunteerId,
        fatherName: fatherName,
        bloodGroup: bloodGroup,
        position: position,
        issueDate: issueDate,
        expiryDate: expiryDate,
      );
      if (result) {
        debugPrint('✅ Volunteer card via EmailJS');
        return true;
      } else {
        debugPrint('❌ EmailJS returned false');
        return false;
      }
    } catch (e) {
      debugPrint('❌ EmailJS volunteer error: $e');
      return false;
    }
  }

  Future<void> _approveVolunteer(Map<String, dynamic> volunteerData, String id) async {
    try {
      final volunteerId = generateVolunteerId();
      final issueDate = DateTime.now();
      final expiryDate = DateTime.now().add(const Duration(days: 365));

      final profileImages = await _getUserProfileImage(volunteerData['userId']);
      final extraFields = await _getUserExtraFields(volunteerData);

      final cardData = {
        'userId': volunteerData['userId'],
        'name': volunteerData['name'] ?? 'Volunteer',
        'volunteerId': volunteerId,
        'fatherName': volunteerData['fatherName'] ?? '',
        'bloodGroup': volunteerData['bloodGroup'] ?? 'Not specified',
        'position': volunteerData['position'] ?? 'Volunteer',
        'issueDate': formatDate(issueDate),
        'expiryDate': formatDate(expiryDate),
        'cnic': extraFields['cnic'],
        'phone': extraFields['phone'],
        'profileImageBase64': profileImages['profileImageBase64'],
        'profileImageUrl': profileImages['profileImageUrl'],
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('cards').add(cardData);
      debugPrint('✅ Card saved to Firestore with CNIC: ${extraFields['cnic']} and Phone: ${extraFields['phone']}');

      await _firestore.updateVolunteerStatus(id, 'approved');
      debugPrint('✅ Volunteer status updated to approved');

      String? email = volunteerData['email'];
      if (email == null || email.isEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(volunteerData['userId'])
            .get();
        if (userDoc.exists) {
          email = userDoc.data()?['email'];
        }
      }

      if (email != null && email.isNotEmpty) {
        final sent = await _sendVolunteerEmail(
          toEmail: email,
          name: volunteerData['name'] ?? 'Volunteer',
          volunteerId: volunteerId,
          fatherName: volunteerData['fatherName'] ?? '',
          bloodGroup: volunteerData['bloodGroup'] ?? 'Not specified',
          position: volunteerData['position'] ?? 'Volunteer',
          issueDate: formatDate(issueDate),
          expiryDate: formatDate(expiryDate),
        );
        if (sent) {
          debugPrint('✅ Volunteer email sent successfully');
        } else {
          debugPrint('❌ Volunteer email failed');
        }
      }

    } catch (e) {
      debugPrint('❌ Error approving volunteer: $e');
      rethrow;
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    if (status == 'approved') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Approve Volunteer'),
          content: const Text('This will save the card to the user\'s "My Cards" section. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Approve'),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      final volunteerDoc = _volunteers.firstWhere(
            (doc) => doc.id == id,
        orElse: () => throw Exception('Volunteer document not found'),
      );

      final volunteerData = volunteerDoc.data() as Map<String, dynamic>;

      try {
        await _approveVolunteer(volunteerData, id);
        _fetchVolunteers(refresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Volunteer approved! Card saved to user\'s "My Cards"'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      await _firestore.updateVolunteerStatus(id, status);
      _fetchVolunteers(refresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Volunteer rejected'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Volunteers'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          DropdownButton<String>(
            value: filterStatus,
            dropdownColor: Colors.white,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'approved', child: Text('Approved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (String? value) {
              setState(() {
                filterStatus = value!;
                _volunteers.clear();
                _lastDocument = null;
                _hasMore = true;
                _isLoading = true;
                _fetchVolunteers(refresh: true);
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => _fetchVolunteers(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _volunteers.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _volunteers.length && _hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final doc = _volunteers[index];
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            final status = data['status'] ?? 'pending';

            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: statusColors[status] ?? Colors.grey,
                  child: Icon(
                    status == 'approved'
                        ? Icons.check
                        : status == 'rejected'
                        ? Icons.close
                        : Icons.pending,
                    color: Colors.white,
                  ),
                ),
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📱 ${data['phone'] ?? 'N/A'}'),
                    if (data['email'] != null)
                      Text('📧 ${data['email']}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColors[status] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailTile('Name', data['name']),
                        _detailTile('Father\'s Name', data['fatherName']),
                        _detailTile('Phone', data['phone']),
                        _detailTile('Email', data['email']),
                        _detailTile('Blood Group', data['bloodGroup']),
                        _detailTile('CNIC', data['cnic']),
                        _detailTile('Address', data['address']),
                        _detailTile('Position', data['position'] ?? 'Volunteer'),
                        _detailTile('Skills', data['skills']),
                        _detailTile('Experience', data['experience']),
                        _detailTile('Availability', data['availability']),
                        if (data['cvFileName'] != null && data['cvBase64'] != null)
                          Row(
                            children: [
                              const Icon(Icons.file_present, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(data['cvFileName']),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => _downloadCV(data['cvBase64'], data['cvFileName']),
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text('Download'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                            ],
                          ),
                        _detailTile('Status', status.toUpperCase()),
                        _detailTile(
                          'Submitted',
                          (data['createdAt'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? 'N/A',
                        ),
                        const SizedBox(height: 16),
                        if (status == 'pending')
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus(id, 'approved'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus(id, 'rejected'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        if (status == 'approved')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '✅ Approved! Card in "My Cards"',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detailTile(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}