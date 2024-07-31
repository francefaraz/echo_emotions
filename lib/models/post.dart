import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String text;
  final String author;
  final Timestamp timestamp;
  int likes;
  int dislikes;

  Post({required this.id, required this.text, required this.author, required this.timestamp, this.likes = 0, this.dislikes = 0});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'] ?? '',
      author: json['author'] ?? '',
      timestamp: json['timestamp'],
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'timestamp': timestamp,
      'likes': likes,
      'dislikes': dislikes,
    };
  }
}
