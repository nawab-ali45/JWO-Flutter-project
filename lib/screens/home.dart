import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/news_ticker.dart';
import 'profile.dart';
import 'donation.dart';
import 'volunteer.dart';
import 'request_help.dart';
import 'my_cards.dart';
import 'contact_us.dart';
import 'about_us.dart';
import 'login.dart';
import 'admin/admin_dashboard.dart';
import 'executive_body.dart';
import 'constitution.dart';
import 'jwo_activities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userData = doc.data();
        _isAdmin = _userData?['role'] == 'admin';
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.green)));
    }

    if (_isAdmin) {
      return const AdminDashboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('JWO Dashboard'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          const NewsTicker(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  const Text('Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _menuCard('My Profile', Icons.person, Colors.blue, const ProfileScreen()),
                        _menuCard('Donation', Icons.favorite, Colors.red, const DonationScreen()),
                        _menuCard('JWO Activities', Icons.emoji_events, Colors.orange, const JWOActivities()),
                        _menuCard('Volunteers', Icons.people, Colors.orange, const VolunteerScreen()),
                        _menuCard('Request Help', Icons.help, Colors.purple, const RequestHelpScreen()),
                        _menuCard('Executive Body', Icons.groups, Colors.teal, const ExecutiveBodyScreen()),
                        _menuCard('Constitution', Icons.book, Colors.brown, const ConstitutionScreen()),
                        _menuCard('My Cards', Icons.card_giftcard, Colors.teal, const MyCardsScreen()),
                        _menuCard('Contact Us', Icons.contact_phone, Colors.teal, const ContactUsScreen()),
                        _menuCard('About Us', Icons.info, Colors.green, const AboutUsScreen()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade500]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/ali.jpeg',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.favorite,
                        size: 22,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Welcome,', style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            _userData?['name']?.split(' ')[0] ?? 'User',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bringing hope with kindness. Join us for a better future and help those in need',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, 2))],
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