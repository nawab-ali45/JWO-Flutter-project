import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/emailjs_service.dart';

class AdminDonations extends StatefulWidget {
  const AdminDonations({super.key});

  @override
  State<AdminDonations> createState() => _AdminDonationsState();
}

class _AdminDonationsState extends State<AdminDonations> {
  String filterStatus = 'All';
  bool _isProcessing = false;
  bool _useFallbackQuery = false;
  final Map<String, bool> _emailStatus = {};

  // ✅ Send verification email using EmailJS
  Future<bool> _sendVerificationEmail({
    required String toEmail,
    required String name,
    required String donationId,
    required double amount,
    required String donationDate,
  }) async {
    if (toEmail.isEmpty) {
      debugPrint('❌ No email address provided');
      return false;
    }

    debugPrint('📧 Attempting to send verification email to: $toEmail');

    try {
      final emailjs = EmailJSService();
      final result = await emailjs.sendDonationVerification(
        toEmail: toEmail,
        name: name,
        donationId: donationId,
        amount: amount,
        donationDate: donationDate,
      );
      if (result) {
        debugPrint('✅ Verification email sent successfully');
        return true;
      } else {
        debugPrint('❌ EmailJS returned false');
        return false;
      }
    } catch (e) {
      debugPrint('❌ EmailJS verification error: $e');
      return false;
    }
  }

  // ❌ Send rejection email using EmailJS
  Future<bool> _sendRejectionEmail({
    required String toEmail,
    required String name,
    required String donationId,
  }) async {
    if (toEmail.isEmpty) {
      debugPrint('❌ No email address provided');
      return false;
    }

    debugPrint('📧 Attempting to send rejection email to: $toEmail');

    try {
      final emailjs = EmailJSService();
      final result = await emailjs.sendDonationRejection(
        toEmail: toEmail,
        name: name,
        donationId: donationId,
      );
      if (result) {
        debugPrint('✅ Rejection email sent successfully');
        return true;
      } else {
        debugPrint('❌ EmailJS returned false');
        return false;
      }
    } catch (e) {
      debugPrint('❌ EmailJS rejection error: $e');
      return false;
    }
  }

  Future<void> _updateStatus(String docId, String newStatus, Map<String, dynamic> data) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance.collection('donations').doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final email = data['email'] ?? '';
      final name = data['name'] ?? 'Donor';
      final donationId = docId.substring(0, 8).toUpperCase();

      bool emailSent = false;

      if (newStatus == 'verified') {
        if (email.isNotEmpty) {
          final amount = (data['amount'] ?? 0).toDouble();
          final donationDate = data['paymentDateTime'] ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
          emailSent = await _sendVerificationEmail(
            toEmail: email,
            name: name,
            donationId: donationId,
            amount: amount,
            donationDate: donationDate,
          );
          setState(() {
            _emailStatus[docId] = emailSent;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                emailSent
                    ? '✅ Verified! Email sent to $email'
                    : '⚠️ Verified but email FAILED to send to $email',
              ),
              backgroundColor: emailSent ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Verified (no email address provided)'), backgroundColor: Colors.green),
          );
        }
      } else if (newStatus == 'rejected') {
        if (email.isNotEmpty) {
          emailSent = await _sendRejectionEmail(
            toEmail: email,
            name: name,
            donationId: donationId,
          );
          setState(() {
            _emailStatus[docId] = emailSent;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                emailSent
                    ? '❌ Rejected! Email sent to $email'
                    : '⚠️ Rejected but email FAILED to send to $email',
              ),
              backgroundColor: emailSent ? Colors.red : Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Rejected (no email address provided)'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Donations'),
        backgroundColor: Colors.green.shade700,
        actions: [
          DropdownButton<String>(
            value: filterStatus,
            dropdownColor: Colors.white,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'verified', child: Text('Verified')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (value) => setState(() => filterStatus = value!),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getDonationsStream(),
              builder: (context, snapshot) {
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
                              'Firestore needs an index to sort your donations.\nClick the button below to create it.',
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
                        Icon(Icons.money_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('No donations'),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs;
                if (filterStatus != 'All') {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == filterStatus;
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;
                    final status = data['status'] ?? 'pending';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: status == 'verified'
                              ? Colors.green
                              : status == 'rejected'
                              ? Colors.red
                              : Colors.orange,
                          child: Icon(
                            status == 'verified'
                                ? Icons.check
                                : status == 'rejected'
                                ? Icons.close
                                : Icons.pending,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(data['name'] ?? 'Unknown'),
                        subtitle: Text('PKR ${data['amount'] ?? 0} • ${data['transactionId'] ?? 'N/A'}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'verified'
                                ? Colors.green
                                : status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
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
                                _detailTile('Email', data['email'] ?? 'No email'),
                                _detailTile('Amount', 'PKR ${data['amount'] ?? 0}'),
                                _detailTile('Transaction ID', data['transactionId'] ?? 'N/A'),
                                _detailTile('Transfer Via', data['transferVia']),
                                _detailTile('Category', data['category']),
                                _detailTile('Payment Date & Time', data['paymentDateTime']),
                                _detailTile('Status', status.toUpperCase()),
                                const SizedBox(height: 16),
                                if (status == 'pending')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isProcessing ? null : () => _updateStatus(id, 'verified', data),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text('Verify & Send Email'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isProcessing ? null : () => _updateStatus(id, 'rejected', data),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (status != 'pending')
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: status == 'verified'
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: status == 'verified'
                                            ? Colors.green.shade200
                                            : Colors.red.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          status == 'verified'
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: status == 'verified' ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          status == 'verified'
                                              ? '✅ Donation Verified'
                                              : '❌ Donation Rejected',
                                          style: TextStyle(
                                            color: status == 'verified' ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (_emailStatus.containsKey(id))
                                          Row(
                                            children: [
                                              Icon(
                                                _emailStatus[id]!
                                                    ? Icons.email
                                                    : Icons.email_outlined,
                                                color: _emailStatus[id]! ? Colors.green : Colors.orange,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _emailStatus[id]! ? 'Sent' : 'Failed',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: _emailStatus[id]! ? Colors.green : Colors.orange,
                                                ),
                                              ),
                                            ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getDonationsStream(),
      builder: (context, snapshot) {
        double total = 0;
        int totalCount = 0;
        int pending = 0;
        int verified = 0;
        int rejected = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0).toDouble();
            final status = data['status'] ?? 'pending';
            totalCount++;
            if (status == 'verified') {
              total += amount;
              verified++;
            } else if (status == 'pending') {
              pending++;
            } else if (status == 'rejected') {
              rejected++;
            }
          }
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Total', 'PKR ${NumberFormat('#,##0.00').format(total)}', Icons.money),
                const SizedBox(width: 16),
                _statItem('Donations', totalCount.toString(), Icons.receipt),
                const SizedBox(width: 16),
                _statItem('Pending', pending.toString(), Icons.pending),
                const SizedBox(width: 16),
                _statItem('Verified', verified.toString(), Icons.check_circle),
                const SizedBox(width: 16),
                _statItem('Rejected', rejected.toString(), Icons.cancel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getDonationsStream() {
    if (_useFallbackQuery) {
      return FirebaseFirestore.instance.collection('donations').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('donations')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  void _openIndexLink() async {
    final Uri url = Uri.parse(
      'https://console.firebase.google.com/v1/r/project/jwo-app/firestore/indexes?create_composite=Ckhwcm9qZWN0cy9qd28tYXBwL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9kb25hdGlvbnMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAolX19uYW11X18QAg',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _detailTile(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}