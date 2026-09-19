import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/news_model.dart';

// ✅ Custom widget for image with error handling
class NetworkImageWithError extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const NetworkImageWithError({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade300,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              SizedBox(height: 8),
              Text('Image not available', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminNews extends StatefulWidget {
  const AdminNews({super.key});

  @override
  State<AdminNews> createState() => _AdminNewsState();
}

class _AdminNewsState extends State<AdminNews> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage News'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          // Add News Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New News',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Content *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL (optional)',
                    hintText: 'https://example.com/image.jpg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Leave empty for no image',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: isLoading ? null : _addNews,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Post News'),
                ),
              ],
            ),
          ),
          // News List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.getNews(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No news posted yet'),
                  );
                }

                final List<QueryDocumentSnapshot> newsItems = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: newsItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> data = newsItems[index].data() as Map<String, dynamic>;
                    final String id = newsItems[index].id;

                    // ✅ Get image URL safely
                    final String? imageUrl = data['imageUrl'] as String?;
                    final bool hasValidImage = imageUrl != null &&
                        imageUrl.isNotEmpty &&
                        !imageUrl.contains('console.firebase');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Using custom widget with null check
                          if (hasValidImage)
                            NetworkImageWithError(
                              imageUrl: imageUrl, // ✅ Now this is a non-null String
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['content'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      data['authorName'] ?? 'Admin',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      (data['createdAt'] as Timestamp?)
                                          ?.toDate()
                                          .toString()
                                          .split(' ')[0] ?? 'N/A',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteNews(id),
                              ),
                            ],
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

  Future<void> _addNews() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final String imageUrl = imageUrlController.text.trim();

      final NewsModel news = NewsModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        content: contentController.text,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        createdAt: DateTime.now(),
        authorId: user!.uid,
        authorName: user.displayName ?? 'Admin',
      );

      await _firestore.createNews(news);

      if (mounted) {
        setState(() {
          isLoading = false;
          titleController.clear();
          contentController.clear();
          imageUrlController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('News posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNews(String id) async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete News'),
        content: const Text('Are you sure you want to delete this news?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _firestore.deleteNews(id);
              if (mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('News deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}