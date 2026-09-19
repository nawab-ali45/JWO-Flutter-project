import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchFacebook() async {
    final Uri url = Uri.parse('https://www.facebook.com/share/1FpuSRAgK2/?mibextid=wwXIfr');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Facebook';
      }
    } catch (e) {
      debugPrint('Error launching Facebook: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, size: 50, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "JWO Welfare Organization",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Non-Profit Organization",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            // About Us Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "About Us",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "JWO Welfare Organization is a non-profit organization committed to improving the lives of underprivileged communities through humanitarian services and social welfare initiatives. Our mission is to provide support to those in need by facilitating donations, volunteer activities, and assistance programs in a transparent and efficient manner.",
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Through this mobile application, we aim to connect donors, volunteers, and beneficiaries on a single platform, making it easier to contribute to meaningful causes and ensure that help reaches deserving individuals promptly.",
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "At JWO, we believe that collective efforts can bring positive change to society. Together, we strive to build a compassionate community where everyone has the opportunity to live with dignity and hope.",
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mission & Vision Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Our Mission",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "To serve humanity by providing accessible, transparent, and technology-driven welfare services.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Our Vision",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "To create a society where no individual is deprived of basic needs and where communities work together to support one another.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Facebook Page Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "جلال فلاحی تنظیم",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "For more information, please visit our official Facebook page:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _launchFacebook,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.facebook, size: 30, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'https://www.facebook.com/share/1FpuSRAgK2/?mibextid=wwXIfr',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _launchFacebook,
                      icon: const Icon(Icons.facebook, color: Colors.white),
                      label: const Text('Visit Facebook Page'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  const Text(
                    "Developed by Nawab Ali S/O Muhammad Ayar",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    "© 2022 JWO Welfare Organization",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}