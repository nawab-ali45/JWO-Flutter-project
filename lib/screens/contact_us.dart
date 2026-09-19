import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _makeCall(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch phone dialer';
      }
    } catch (e) {
      debugPrint('Error making call: $e');
      // You can add a SnackBar here to show error
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@jwo.org.pk',
      query: 'subject=Inquiry about JWO Services',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.contact_phone,
                size: 60,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Get in Touch",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "We're here to help and answer any questions",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            // Office Contact
            _contactCard(
              icon: Icons.business_center,
              title: "Office",
              number: "+92 341 5566663",
              color: Colors.blue,
              onTap: () => _makeCall("+923415566663"),
            ),
            const SizedBox(height: 12),

            // Ambulance Service
            _contactCard(
              icon: Icons.local_hospital,
              title: "Ambulance Service",
              number: "+92 341 5566664",
              color: Colors.red,
              onTap: () => _makeCall("+923415566664"),
            ),
            const SizedBox(height: 12),

            // App Management
            _contactCard(
              icon: Icons.admin_panel_settings,
              title: "App Management",
              number: "+92 306 8188894",
              color: Colors.green,
              onTap: () => _makeCall("+923068188894"),
            ),
            const SizedBox(height: 12),

            // Email Contact
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.email, color: Colors.orange.shade700),
                ),
                title: const Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "jalalfalahitanzeem@gmail.com",
                  style: TextStyle(color: Colors.blue.shade700),
                ),
                trailing: const Icon(Icons.email, color: Colors.orange),
                onTap: _sendEmail,
              ),
            ),

            const SizedBox(height: 30),

            // Office Hours Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: Colors.green.shade700),
                        const SizedBox(width: 10),
                        const Text(
                          "Office Hours",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildTimeRow('Monday - Friday', '9:00 AM - 6:00 PM'),
                    const Divider(height: 12),
                    _buildTimeRow('Saturday', '10:00 AM - 2:00 PM'),
                    const Divider(height: 12),
                    _buildTimeRow('Sunday', 'Closed', isClosed: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Emergency Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "For emergencies, please call the Ambulance Service number directly.",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const Text(
                    "Developed by Nawab Ali S/O Muhammad Ayar",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "© ${DateTime.now().year} JWO Welfare Organization",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String number,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          number,
          style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.phone, color: Colors.green.shade700, size: 20),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTimeRow(String day, String time, {bool isClosed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isClosed ? Colors.red : Colors.grey.shade800,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontWeight: isClosed ? FontWeight.bold : FontWeight.normal,
              color: isClosed ? Colors.red : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}