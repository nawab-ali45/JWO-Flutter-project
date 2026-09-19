import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'admin_news.dart';
import 'admin_volunteers.dart';
import 'admin_requests.dart';
import 'admin_donations.dart';
import 'admin_activities.dart';
import '../login.dart';
import '../home.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestore = FirestoreService();
  int userCount = 0;
  double totalDonations = 0;
  int pendingRequests = 0;
  int pendingVolunteers = 0;
  bool isLoading = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        setState(() => _isAuthorized = true);
        await loadStats();
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking admin access: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> loadStats() async {
    setState(() => isLoading = true);
    try {
      userCount = await _firestore.getUserCount();

      final donationSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('status', isEqualTo: 'verified')
          .get();

      double verifiedTotal = 0;
      for (var doc in donationSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        verifiedTotal += (data['amount'] ?? 0).toDouble();
      }
      totalDonations = verifiedTotal;

      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingRequests = requestsSnapshot.docs.length;

      final volunteersSnapshot = await FirebaseFirestore.instance
          .collection('volunteers')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingVolunteers = volunteersSnapshot.docs.length;

    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
    if (mounted) setState(() => isLoading = false);
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
    if (!_isAuthorized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.shade700, Colors.green.shade500],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👋 Welcome Admin!',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your organization from here',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Grid - 4 cards only
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('👥 Users', userCount.toString(), Colors.blue),
                _buildStatCard(
                  '💰 Total Donations',
                  'PKR ${totalDonations.toStringAsFixed(0)}',
                  Colors.green,
                ),
                _buildStatCard('📝 Pending Requests', pendingRequests.toString(), Colors.orange),
                _buildStatCard('🙋 Pending Volunteers', pendingVolunteers.toString(), Colors.purple),
              ],
            ),
            const SizedBox(height: 20),

            // Manage Section
            const Text(
              'Manage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildAdminCard('Manage News', Icons.newspaper, Colors.blue, () {
                  if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNews()));
                }),
                _buildAdminCard('Manage Volunteers', Icons.people, Colors.orange, () {
                  if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminVolunteers()));
                }),
                _buildAdminCard('Manage Requests', Icons.help, Colors.purple, () {
                  if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequests()));
                }),
                _buildAdminCard('Manage Donations', Icons.favorite, Colors.red, () {
                  if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDonations()));
                }),
                _buildAdminCard('Manage Activities', Icons.emoji_events, Colors.teal, () {
                  if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminActivities()));
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAdminCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}