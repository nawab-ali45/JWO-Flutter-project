import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  bool _useFallbackQuery = true;
  final GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your cards')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cards'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveCardImage,
            tooltip: 'Save Card',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getCardsStream(userId),
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
                        'Firestore needs an index to sort your cards.\nYou can use the fallback mode below.',
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
                  Icon(Icons.card_giftcard, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No cards yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Complete a volunteer application to get a card',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final List<QueryDocumentSnapshot> cards = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> data = cards[index].data() as Map<String, dynamic>;
              return RepaintBoundary(
                key: index == 0 ? _cardKey : GlobalKey(),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildCardItem(context, data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getCardsStream(String userId) {
    if (_useFallbackQuery) {
      return FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  void _openIndexLink() async {
    final Uri url = Uri.parse(
      'https://console.firebase.google.com/v1/r/project/jwo-app/firestore/indexes?create_composite=CkVwcm9qZWN0cy9qd28tYXBwL2RhdGFiYXNIqy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9jYXJkcy9pbmRleGVzL1ARoKCgZ1c2VySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveCardImage() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving card...'), backgroundColor: Colors.blue),
        );
      }

      RenderRepaintBoundary? boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture card'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to convert image'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'JWO_Volunteer_Card.png')
          ..click();
        html.Url.revokeObjectUrl(url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Card downloaded!'), backgroundColor: Colors.green),
          );
        }
      } else {
        await Gal.putImageBytes(pngBytes, album: 'JWO');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Card saved to gallery!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildCardItem(BuildContext context, Map<String, dynamic> data) {
    String? imageData;
    if (data['profileImageBase64'] != null && data['profileImageBase64'].isNotEmpty) {
      imageData = data['profileImageBase64'];
    } else if (data['profileImageUrl'] != null && data['profileImageUrl'].isNotEmpty) {
      imageData = data['profileImageUrl'];
    } else if (data['profileImage'] != null && data['profileImage'].isNotEmpty) {
      imageData = data['profileImage'];
    }

    final Widget logo = Image.asset(
      'assets/icons/ali.jpeg',
      width: 45,
      height: 45,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade300, width: 1.5),
          ),
          child: const Center(
            child: Text(
              'JWO',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );

    final List<Map<String, String>> fields = [
      {'label': 'Name', 'value': data['name'] ?? ''},
      {'label': "Father's Name", 'value': data['fatherName'] ?? ''},
      {'label': 'CNIC No', 'value': data['cnic'] ?? 'N/A'},
      {'label': 'Phone No', 'value': data['phone'] ?? 'N/A'},
      {'label': 'Blood Group', 'value': data['bloodGroup'] ?? ''},
      {'label': 'Position', 'value': data['position'] ?? ''},
      {'label': 'Volunteer ID', 'value': data['volunteerId'] ?? ''},
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade700, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withAlpha(128),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    logo,
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JALAL WELFARE ORGANIZATION',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          'Volunteer Identity Card',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite,
                      color: Colors.green.shade700,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 16, thickness: 1),
            const SizedBox(height: 8),
            // Main Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildProfileImage(imageData, data['name'] ?? 'Volunteer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: fields.map((field) {
                      return _detailRow(field['label']!, field['value']!);
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateChip('Issue Date', data['issueDate'] ?? ''),
                _dateChip('Expiry Date', data['expiryDate'] ?? ''),
              ],
            ),
            const SizedBox(height: 10),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💚 Save Humanity',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'www.jalalwelfare.org',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '𝓠𝓪𝓶𝓪𝓻 𝓩𝓪𝓭𝓪',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Brush Script MT',
                      ),
                    ),
                    const Text(
                      'Authorized Signatory',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                    const Text(
                      'Jalal Welfare Organization',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Contact Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _contactItem(Icons.phone, '+92 341 5566663'),
                  _contactItem(Icons.facebook, 'جلال فلاحی تنظیم'),
                  _contactItem(Icons.public, 'www.jalalwelfare.org'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _dateChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 8,
            ),
          ),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: TextStyle(
              color: Colors.green.shade800,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageData, String name) {
    if (imageData == null || imageData.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 32, color: Colors.green.shade700),
              Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    try {
      String base64String = imageData;
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      base64String = base64String.replaceAll(RegExp(r'\s+'), '');
      final Uint8List bytes = base64Decode(base64String);
      if (bytes.isNotEmpty) {
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage(name);
          },
        );
      }
    } catch (e) {
      if (imageData.startsWith('http')) {
        return Image.network(
          imageData,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage(name);
          },
        );
      }
    }
    return _buildFallbackImage(name);
  }

  Widget _buildFallbackImage(String name) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 32, color: Colors.green.shade700),
            Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}