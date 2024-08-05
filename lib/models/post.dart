import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String text;
  final String author;
  final String userId;
  final String category;
  final Timestamp timestamp;
  int likes;
  int dislikes;

  Post({
    required this.id,
    required this.text,
    required this.author,
    required this.userId,
    this.category = "quotes",
    required this.timestamp,
    this.likes = 0,
    this.dislikes = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Debugging statement to print JSON data
    print("json data from post is ${json}");
    final timestamp = json['timestamp'] is Timestamp
        ? json['timestamp'] as Timestamp
        : Timestamp.fromDate(DateTime.now()); // Default value if missing or invalid
    return Post(
      id: json['id'] ?? '', // Default to empty string if null
      text: json['text'] ?? '',
      author: json['author'] ?? '',
      userId: json['userId'] ?? '',
      category: json['category'] ?? 'quotes',
      timestamp: timestamp, // Ensure 'timestamp' is a Timestamp
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'userId': userId,
      'category': category,
      'timestamp': timestamp,
      'likes': likes,
      'dislikes': dislikes,
    };
  }
}
