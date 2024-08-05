import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_emotions/models/post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  bool _isModalVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Sharing App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error: Something went wrong');
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Post.fromJson(data);
                }).toList();

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                      'https://static.figma.com/app/icon/1/touch-180.png'),
                                ),
                                const SizedBox(width: 16.0),
                                Text(
                                  post.author ?? 'Muneer',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(post.text),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up),
                                      onPressed: post.id != null ? () => _likePost(post.id!) : null,
                                    ),
                                    Text('${post.likes}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.thumb_down),
                                      onPressed: post.id != null ? () => _dislikePost(post.id!) : null,
                                    ),
                                    Text('${post.dislikes}'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleModal,
        child: const Icon(Icons.add),
      ),
      bottomSheet: _isModalVisible ? _buildModal() : null,
    );
  }

  Widget _buildModal() {
    return BottomSheet(
      onClosing: () => _toggleModal(),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(hintText: 'Write your post'),
              ),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(hintText: 'Enter author name'),
              ),
              ElevatedButton(
                onPressed: () {
                  _createPost(_textController.text, _authorController.text);
                  _toggleModal();
                },
                child: const Text('Share'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleModal() {
    if (!isUserLoggedIn()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a post')),
      );
      Navigator.pushNamed(context, '/authentication');
    } else {
      setState(() {
        _isModalVisible = !_isModalVisible;
      });
    }
  }

  void _createPost(String text, String author) async {
    if (await isPostExists(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post already exists')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a post')),
      );
      return;
    }

    final userId = user.uid;

    final docRef = await FirebaseFirestore.instance.collection('posts').add({
      'text': text,
      'author': user.displayName ?? user.email,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'dislikes': 0,
    });

    final post = Post(
      id: docRef.id,
      text: text,
      author: author.isNotEmpty ? author : user.email?.split('@')[0] ?? 'Anonymous',
      userId: userId,
      timestamp: Timestamp.now(),
    );

    try {
      await docRef.set(post.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating post')),
      );
    }
  }

  void _likePost(String postId) async {
    print("posting id is " + postId);
    if (!isUserLoggedIn()) {
      Navigator.pushNamed(context, '/authentication');
    } else {
      try {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.increment(1),
        });
      } catch (e) {
        print('Error liking post: $e');
      }
    }
  }

  void _dislikePost(String postId) async {
    if (!isUserLoggedIn()) {
      Navigator.pushNamed(context, '/authentication');
    } else {
      try {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'dislikes': FieldValue.increment(1),
        });
      } catch (e) {
        print('Error disliking post: $e');
      }
    }
  }

  bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<bool> isPostExists(String text) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('text', isEqualTo: text)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
