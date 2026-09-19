import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestHelpScreen extends StatefulWidget {
  const RequestHelpScreen({super.key});

  @override
  State<RequestHelpScreen> createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController requestController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController urgencyController = TextEditingController();

  bool isLoading = false;
  // ✅ Default to fallback to avoid index errors
  bool _useFallbackQuery = true;

  final List<String> requestTypes = [
    'Medical Assistance',
    'Food Support',
    'Education Help',
    'Shelter',
    'Financial Aid',
    'Emergency Support',
    'Other'
  ];
  final List<String> urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Request Help"),
          backgroundColor: Colors.green.shade700,
          bottom: const TabBar(
            tabs: [
              Tab(text: "New Request", icon: Icon(Icons.add)),
              Tab(text: "My Requests", icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewRequestTab(),
            _buildMyRequestsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.help_center, size: 60, color: Colors.purple),
          const SizedBox(height: 10),
          const Text(
            "We're Here to Help",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Full Name *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: fatherController,
            decoration: InputDecoration(
              labelText: "Father's Name *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.family_restroom, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: "Phone Number *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.phone, color: Colors.green.shade700),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cnicController,
            decoration: InputDecoration(
              labelText: "CNIC Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.badge, color: Colors.green.shade700),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: "Address *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.location_on, color: Colors.green.shade700),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Request Type *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.category, color: Colors.green.shade700),
            ),
            items: requestTypes.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            )).toList(),
            onChanged: (v) => typeController.text = v!,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Urgency Level *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.priority_high, color: Colors.green.shade700),
            ),
            items: urgencyLevels.map((level) => DropdownMenuItem(
              value: level,
              child: Text(level),
            )).toList(),
            onChanged: (v) => urgencyController.text = v!,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: requestController,
            decoration: InputDecoration(
              labelText: "Request Description *",
              hintText: "Please provide detailed information about your situation",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.description, color: Colors.green.shade700),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _submitRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text(
              "Submit Request",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRequestsTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please login to view your requests'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _getRequestsStream(user.uid),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error.toString();
          if (error.contains('requires an index') || error.contains('failed-precondition')) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, size: 60, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Index Required',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Firestore needs an index to display your requests.\nYou can use the fallback mode below.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _openIndexLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Index in Firebase Console'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _useFallbackQuery = true;
                        });
                      },
                      child: const Text('Use fallback (no sorting)'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  'No requests yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  'Submit a request to get help',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final List<QueryDocumentSnapshot> requests = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> data = requests[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(status),
                  child: _getStatusIcon(status),
                ),
                title: Text(data['need'] ?? 'Request'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['request'] ?? ''),
                    const SizedBox(height: 4),
                    Text(
                      '📅 ${(data['timestamp'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? 'N/A'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _showRequestDetails(context, data),
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getRequestsStream(String userId) {
    if (_useFallbackQuery) {
      // ✅ Fallback: no sorting, avoids index error
      return FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  void _openIndexLink() async {
    final Uri url = Uri.parse(
      'https://console.firebase.google.com/v1/r/project/jwo-app/firestore/indexes?create_composite=Ckhwcm9qZWN0cy9qd28tYXBwL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9yZXF1ZXN0cy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgl0aW1lc3RhbXAQAhoMCghfX25hbWVfXxAC',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitRequest() async {
    if (nameController.text.isEmpty || fatherController.text.isEmpty ||
        phoneController.text.isEmpty || requestController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('requests').add({
        "name": nameController.text,
        "fatherName": fatherController.text,
        "phone": phoneController.text,
        "cnic": cnicController.text.isNotEmpty ? cnicController.text : null,
        "address": addressController.text.isNotEmpty ? addressController.text : null,
        "need": typeController.text.isNotEmpty ? typeController.text : 'General',
        "urgency": urgencyController.text.isNotEmpty ? urgencyController.text : 'Medium',
        "request": requestController.text,
        "userId": user!.uid,
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Request submitted! We'll contact you soon."),
          backgroundColor: Colors.green,
        ),
      );

      nameController.clear();
      fatherController.clear();
      phoneController.clear();
      cnicController.clear();
      addressController.clear();
      requestController.clear();
      typeController.clear();
      urgencyController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(request['need'] ?? 'Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailTile('Name', request['name']),
              _detailTile('Father\'s Name', request['fatherName']),
              _detailTile('Phone', request['phone']),
              _detailTile('CNIC', request['cnic']),
              _detailTile('Address', request['address']),
              _detailTile('Urgency', request['urgency']),
              _detailTile('Status', request['status']?.toUpperCase() ?? 'PENDING'),
              _detailTile('Submitted', request['timestamp']?.toString().split(' ')[0] ?? 'N/A'),
              const SizedBox(height: 8),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request['request'] ?? ''),
            ],
          ),
        ),
        actions: [
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
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return const Icon(Icons.check, color: Colors.white, size: 20);
      case 'rejected':
        return const Icon(Icons.close, color: Colors.white, size: 20);
      default:
        return const Icon(Icons.pending, color: Colors.white, size: 20);
    }
  }
}