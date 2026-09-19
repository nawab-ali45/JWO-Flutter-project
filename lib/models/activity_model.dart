import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String title;
  final String description;
  final String? url; // Can be image or video URL
  final DateTime createdAt;
  final String authorId;
  final String authorName;
  final bool isPublished;
  final int viewCount;

  ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    this.url,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
    this.isPublished = true,
    this.viewCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'createdAt': createdAt,
      'authorId': authorId,
      'authorName': authorName,
      'isPublished': isPublished,
      'viewCount': viewCount,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Admin',
      isPublished: map['isPublished'] ?? true,
      viewCount: map['viewCount'] ?? 0,
    );
  }
}