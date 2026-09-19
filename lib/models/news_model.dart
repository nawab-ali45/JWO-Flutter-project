class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final String authorId;
  final String authorName;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'authorId': authorId,
      'authorName': authorName,
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map, String id) {
    return NewsModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
    );
  }
}