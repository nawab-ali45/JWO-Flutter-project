import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class AdminRequests extends StatefulWidget {
  const AdminRequests({super.key});

  @override
  State<AdminRequests> createState() => _AdminRequestsState();
}

class _AdminRequestsState extends State<AdminRequests> {
  final FirestoreService _firestore = FirestoreService();
  String filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Requests'),
        backgroundColor: Colors.green.shade700,
        actions: [
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
              setState(() => filterStatus = value!);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
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
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No requests', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          var requests = snapshot.data!.docs;
          if (filterStatus != 'All') {
            requests = requests.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == filterStatus;
            }).toList();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = requests[index];
              final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              final String id = doc.id;
              final String status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: _getStatusIcon(status),
                  ),
                  title: Text(data['name'] ?? 'Unknown'),
                  subtitle: Text('📱 ${data['phone'] ?? 'N/A'}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailTile('Name', data['name']),
                          _detailTile('Father\'s Name', data['fatherName']),
                          _detailTile('Phone', data['phone']),
                          _detailTile('CNIC', data['cnic']),
                          _detailTile('Address', data['address']),
                          _detailTile('Need', data['need']),
                          _detailTile('Urgency', data['urgency']),
                          _detailTile('Description', data['request']),
                          _detailTile('Status', status.toUpperCase()),
                          _detailTile(
                            'Submitted',
                            (data['timestamp'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? 'N/A',
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
                                      '✅ Approved',
                                      style: const TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (status == 'rejected')
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cancel, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '❌ Rejected',
                                      style: const TextStyle(color: Colors.red),
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
          );
        },
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

  Future<void> _updateStatus(String id, String status) async {
    await _firestore.updateRequestStatus(id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request ${status == 'approved' ? 'approved' : 'rejected'}'),
        backgroundColor: status == 'approved' ? Colors.green : Colors.red,
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