import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class NewsTicker extends StatefulWidget {
  const NewsTicker({super.key});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  final FirestoreService _firestore = FirestoreService();
  late ScrollController _scrollController;
  Timer? _timer;
  List<QueryDocumentSnapshot> _newsItems = [];
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (_newsItems.isEmpty) return;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients && !_isPaused && _newsItems.isNotEmpty) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double currentScroll = _scrollController.offset;

        // Continuous right-to-left scrolling
        if (currentScroll >= maxScroll - 1) {
          // Jump back to start smoothly
          _scrollController.jumpTo(0);
        } else {
          // Scroll right
          _scrollController.jumpTo(currentScroll + 1);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getNews(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 45,
            color: Colors.green.shade50,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('❌ NewsTicker error: ${snapshot.error}');
          return Container(
            height: 45,
            color: Colors.orange.shade100,
            child: const Center(
              child: Text('📰 Unable to load news', style: TextStyle(color: Colors.black54)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            height: 45,
            color: Colors.green.shade50,
            child: const Center(
              child: Text(
                '📰 Welcome to JWO! Stay tuned for updates.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        _newsItems = snapshot.data!.docs;

        // Start auto-scroll after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_timer == null || !_timer!.isActive) {
            _startAutoScroll();
          }
        });

        // Build the ticker items
        final List<Widget> items = [];
        // Duplicate items for seamless scrolling
        for (int i = 0; i < _newsItems.length * 2; i++) {
          final int index = i % _newsItems.length;
          final Map<String, dynamic> data = _newsItems[index].data() as Map<String, dynamic>;
          final String title = data['title'] ?? 'News';
          final String content = data['content'] ?? '';
          items.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.newspaper, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '📰 $title',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('•', style: TextStyle(color: Colors.grey.shade400)),
                  const SizedBox(width: 12),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          height: 45,
          color: Colors.green.shade50,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPaused = true),
            onTapUp: (_) => setState(() => _isPaused = false),
            onTapCancel: () => setState(() => _isPaused = false),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return items[index];
              },
            ),
          ),
        );
      },
    );
  }
}