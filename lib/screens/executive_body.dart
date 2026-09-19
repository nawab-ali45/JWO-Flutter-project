import 'package:flutter/material.dart';

class ExecutiveBodyScreen extends StatelessWidget {
  const ExecutiveBodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Executive Body", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: "🇵🇰 Pakistan", icon: Icon(Icons.location_on)),
              Tab(text: "🇸🇦 Saudi Arabia", icon: Icon(Icons.location_on)),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            PakistanExecutiveBody(),
            SaudiExecutiveBody(),
          ],
        ),
      ),
    );
  }
}

// ==================== PAKISTAN EXECUTIVE BODY ====================
class PakistanExecutiveBody extends StatelessWidget {
  const PakistanExecutiveBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🇵🇰 Jalal Welfare Organization',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Executive Body - Pakistan',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '🏛️ Executive Leadership',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          _buildCommitteeCard(
            title: 'President',
            name: 'Qamar Zada',
            description: 'Leading the organization with vision and dedication.',
            icon: Icons.person,
          ),
          _buildCommitteeCard(
            title: 'Vice President',
            name: 'Lajbar Khan',
            description: 'Supporting the President in strategic initiatives.',
            icon: Icons.person,
          ),
          _buildCommitteeCard(
            title: 'Senior Vice President',
            name: 'Irfan Ullah',
            description: 'Overseeing key organizational functions.',
            icon: Icons.person,
          ),
          _buildCommitteeCard(
            title: 'General Secretary',
            name: 'Jehan Zada',
            description: 'Managing administrative affairs and coordination.',
            icon: Icons.description,
          ),
          _buildCommitteeCard(
            title: 'Finance Secretary',
            name: 'Amir Sawab',
            description: 'Overseeing financial management and transparency.',
            icon: Icons.attach_money,
          ),
          _buildCommitteeCard(
            title: 'Deputy Finance Secretary',
            name: 'Najmuddin Khan',
            description: 'Assisting in financial operations and reporting.',
            icon: Icons.attach_money,
          ),
          _buildCommitteeCard(
            title: 'Information Secretary',
            name: 'Akbar Zaib',
            description: 'Managing communications and public relations.',
            icon: Icons.info,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📢 Information Coordinators',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                MemberTile(name: 'Amjad Ali'),
                MemberTile(name: 'Zia Ullah'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📱 Media Team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                MemberTile(name: 'Amjad Ali'),
                MemberTile(name: 'Zia Ullah'),
                MemberTile(name: 'Fayaz Mashal'),
                MemberTile(name: 'Tariq Khan'),
                MemberTile(name: 'Akbar Zaib'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💻 App Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                MemberTile(name: 'Nawab Ali'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitteeCard({
    required String title,
    required String name,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar + Name + Title
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(icon, color: Colors.green.shade700, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SAUDI ARABIA EXECUTIVE BODY ====================
class SaudiExecutiveBody extends StatelessWidget {
  const SaudiExecutiveBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🇸🇦 Jalal Welfare Organization',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Executive Body - Saudi Arabia',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '🏛️ Executive Leadership - Saudi Arabia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          _buildCommitteeCard(
            title: 'President',
            name: 'Sheer Zamin Khan',
            description: 'Leading the organization with vision and dedication.',
            icon: Icons.person,
            color: Colors.red,
          ),
          _buildCommitteeCard(
            title: 'Vice President',
            name: 'Gul Nawaz Khan',
            description: 'Supporting the President in strategic initiatives.',
            icon: Icons.person,
            color: Colors.red.shade300,
          ),
          _buildCommitteeCard(
            title: 'Senior Vice President',
            name: 'Muhammad Ambar',
            description: 'Overseeing key organizational functions.',
            icon: Icons.person,
            color: Colors.red.shade300,
          ),
          _buildCommitteeCard(
            title: 'General Secretary',
            name: 'Saqib Ullah',
            description: 'Managing administrative affairs and coordination.',
            icon: Icons.description,
            color: Colors.blue,
          ),
          _buildCommitteeCard(
            title: 'Deputy General Secretary',
            name: 'Zafar Khan',
            description: 'Assisting in administrative affairs.',
            icon: Icons.description,
            color: Colors.blue,
          ),
          _buildCommitteeCard(
            title: 'Joint Secretary',
            name: 'Miraj Khan',
            description: 'Supporting the General Secretary in coordination.',
            icon: Icons.description,
            color: Colors.blue,
          ),
          _buildCommitteeCard(
            title: 'Chief Organizer',
            name: 'Abdul Karim & Afzal Khan',
            description: 'Overseeing organizational activities and events.',
            icon: Icons.groups,
            color: Colors.teal,
          ),
          _buildCommitteeCard(
            title: 'Information Secretary',
            name: 'Nek Amal Khan & Sikandar Khan',
            description: 'Managing communications and public relations.',
            icon: Icons.info,
            color: Colors.orange,
          ),
          _buildCommitteeCard(
            title: 'Deputy Information Secretary',
            name: 'Fazal Rahim Khan',
            description: 'Assisting in communications and media relations.',
            icon: Icons.info,
            color: Colors.orange,
          ),
          _buildCommitteeCard(
            title: 'Finance Secretary',
            name: 'Taseer Khan',
            description: 'Overseeing financial management and transparency.',
            icon: Icons.attach_money,
            color: Colors.cyan,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyan.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💰 Finance Assistants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
                SizedBox(height: 8),
                MemberTile(name: 'Sultan Zayb'),
                MemberTile(name: 'Fateh Bar Khan'),
                MemberTile(name: 'Rahim Zada'),
                MemberTile(name: 'Sher Wali'),
                MemberTile(name: 'Aziz Ullah'),
                MemberTile(name: 'Ikram Ullah'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📱 Media Group',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                MemberTile(name: 'Fayaz'),
                MemberTile(name: 'Rehan Khan'),
                MemberTile(name: 'Zia Ullah'),
                MemberTile(name: 'Rahman Rahi'),
                MemberTile(name: 'Akbar Zayb'),
                MemberTile(name: 'Tariq Khan'),
                MemberTile(name: 'Sher Nawab'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👤 Senior Advisor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 8),
                MemberTile(name: 'Gul Lali Baba'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitteeCard({
    required String title,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar + Name + Title
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MEMBER TILE WIDGET ====================
class MemberTile extends StatelessWidget {
  const MemberTile({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.person_outline, size: 14, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14, height: 1.4),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}