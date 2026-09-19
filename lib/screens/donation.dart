import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController transactionIdController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController paymentDateTimeController = TextEditingController();

  String selectedTransferVia = 'JazzCash';
  bool isLoading = false;
  bool _useFallbackQuery = true; // ✅ Default to fallback to avoid index error

  final List<String> transferMethods = ['JazzCash', 'EasyPaisa', 'Bank Transfer', 'Credit/Debit Card'];
  final List<String> donationCategories = ['Zakat', 'Sadaqah', 'General Donation', 'Food Program', 'Education', 'Medical', 'Emergency Relief'];

  final FirestoreService _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    paymentDateTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          paymentDateTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(combined);
        });
      }
    }
  }

  Future<void> submitDonation() async {
    if (nameController.text.isEmpty ||
        fatherNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        amountController.text.isEmpty ||
        categoryController.text.isEmpty) {
      _showMessage('Please fill all required fields', Colors.red);
      return;
    }

    final double amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      _showMessage('Enter valid amount', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Please login first', Colors.red);
      setState(() => isLoading = false);
      return;
    }

    try {
      final String? transactionId = transactionIdController.text.isNotEmpty
          ? transactionIdController.text
          : null;

      await FirebaseFirestore.instance.collection('donations').add({
        'name': nameController.text,
        'fatherName': fatherNameController.text,
        'email': emailController.text,
        'amount': amount,
        'transactionId': transactionId,
        'transferVia': selectedTransferVia,
        'category': categoryController.text,
        'paymentDateTime': paymentDateTimeController.text,
        'userId': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showMessage('✅ Donation submitted for verification!', Colors.green);

      nameController.clear();
      fatherNameController.clear();
      emailController.clear();
      amountController.clear();
      transactionIdController.clear();
      categoryController.clear();
      paymentDateTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    } catch (e) {
      _showMessage('Error: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Donations'),
          backgroundColor: Colors.green.shade700,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'New Donation', icon: Icon(Icons.add)),
              Tab(text: 'My Donations', icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewDonationTab(),
            _buildMyDonationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewDonationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donation Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Card Holder Name *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: fatherNameController,
            decoration: InputDecoration(
              labelText: 'Father\'s Name *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.family_restroom, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email Address *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.email, color: Colors.green.shade700),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: 'Amount (PKR) *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.currency_rupee, color: Colors.green.shade700),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: transactionIdController,
            decoration: InputDecoration(
              labelText: 'Transaction ID (optional)',
              hintText: 'Leave empty if not available',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.receipt, color: Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedTransferVia,
            decoration: InputDecoration(
              labelText: 'Transfer Via *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.payment, color: Colors.green.shade700),
            ),
            items: transferMethods.map((method) {
              return DropdownMenuItem(value: method, child: Text(method));
            }).toList(),
            onChanged: (value) => setState(() => selectedTransferVia = value!),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: categoryController.text.isNotEmpty ? categoryController.text : null,
            decoration: InputDecoration(
              labelText: 'Donation Category *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.category, color: Colors.green.shade700),
            ),
            items: donationCategories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) => categoryController.text = value!,
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => _selectDateTime(context),
            child: AbsorbPointer(
              child: TextField(
                controller: paymentDateTimeController,
                decoration: InputDecoration(
                  labelText: 'Payment Date & Time *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.green.shade700),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: isLoading ? null : submitDonation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Submit for Verification', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildMyDonationsTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please login to view your donations'));
    }

    return Column(
      children: [
        _buildStatsCard(user.uid),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getDonationsStream(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // ✅ Show error but not the index creation button
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
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
                      Icon(Icons.money_off, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No donations yet'),
                    ],
                  ),
                );
              }

              final donations = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final data = donations[index].data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';

                  Color statusColor;
                  IconData statusIcon;
                  switch (status) {
                    case 'verified':
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                      break;
                    case 'rejected':
                      statusColor = Colors.red;
                      statusIcon = Icons.cancel;
                      break;
                    default:
                      statusColor = Colors.orange;
                      statusIcon = Icons.pending;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor,
                        child: Icon(statusIcon, color: Colors.white),
                      ),
                      title: Text('PKR ${data['amount'] ?? 0}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${data['category'] ?? 'N/A'}'),
                          Text('Status: ${status.toUpperCase()}'),
                          Text('Date: ${data['paymentDateTime'] ?? 'N/A'}'),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () => _showDonationDetails(data),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        double totalDonations = 0;
        double currentDonations = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0).toDouble();
            final status = data['status'] ?? 'pending';
            if (status == 'verified') {
              totalDonations += amount;
            } else if (status == 'pending') {
              currentDonations += amount;
            }
          }
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Total Donations', 'PKR ${NumberFormat('#,##0.00').format(totalDonations)}', Icons.money),
              _statItem('Pending', 'PKR ${NumberFormat('#,##0.00').format(currentDonations)}', Icons.pending),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getDonationsStream(String userId) {
    // ✅ Always use fallback (no sorting) to avoid index errors
    return FirebaseFirestore.instance
        .collection('donations')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  void _showDonationDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Donation Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailTile('Name', data['name']),
              _detailTile('Father\'s Name', data['fatherName']),
              _detailTile('Email', data['email']),
              _detailTile('Amount', 'PKR ${data['amount'] ?? 0}'),
              _detailTile('Transaction ID', data['transactionId'] ?? 'N/A'),
              _detailTile('Transfer Via', data['transferVia']),
              _detailTile('Category', data['category']),
              _detailTile('Payment Date & Time', data['paymentDateTime']),
              _detailTile('Status', data['status']?.toString().toUpperCase() ?? 'PENDING'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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