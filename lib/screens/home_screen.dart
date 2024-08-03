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
              stream:
                  FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error: Something went wrong');
                }

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final posts = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  // Handle potential null values here
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
                            // Row     for profile picture and author name
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                      'https://example.com/avatar.jpg'), // Replace with actual image URL
                                ),
                                const SizedBox(width: 16.0),
                                Text(post.author,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            // Post text
                            Text(post.text),
                            const SizedBox(height: 8.0),
                            // Row for likes and dislikes (optional)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // const Icon(Icons.thumb_up,
                                    //     color: Colors.blue),
                                    // const SizedBox(width: 4.0),
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up),
                                      onPressed: post.id != null ? () => _likePost(post.id!) : null,
                                    ),
                                    Text('${post.likes}'),

                                  ],
                                ),
                                Row(
                                  children: [
                                    // const Icon(Icons.thumb_down,
                                    //     color: Colors.red),
                                    // const SizedBox(width: 4.0),
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

                /*return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    // return ListTile(
                    //   title: Text(post.text ?? 'No text'), // Handle null text
                    //   subtitle: Text('By ${post.author} - ${post.likes} likes - ${post.dislikes} dislikes'),
                    //   // subtitle: Text('${post.likes ?? 0} likes - ${post.dislikes ?? 0} dislikes'),
                    return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage('https://example.com/avatar.jpg'), // Replace with actual image URL
                        ),
                        title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text(post.author, style: TextStyle(fontWeight: FontWeight.bold)),

                        const SizedBox(height: 8),
                    Text(post.text),
                    ],
                    ),
                    trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: post.id != null ? () => _likePost(post.id!) : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.thumb_down),
                            onPressed: post.id != null ? () => _dislikePost(post.id!) : null,
                          ),
                        ],
                      ),
                    );
                  },
                );  */
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
    final _textController = TextEditingController();

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
                decoration:
                    const InputDecoration(hintText: 'Enter author name'),
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
    setState(() {
      _isModalVisible = !_isModalVisible;
    });
  }

  void _createPost(String text, String author) async {
    final doc = await FirebaseFirestore.instance.collection('posts').add({});
    final post = Post(
      id: doc.id,
      text: text,
      author: author,
      timestamp: Timestamp.now(),
    );

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(doc.id)
          .set(post.toJson());
      // Add a snackbar or other feedback for successful post creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
    } catch (e) {
      print('Error creating post: $e');
      // Add a snackbar or other feedback for failed post creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating post')),
      );
    }
  }

  void _likePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  void _dislikePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'dislikes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error disliking post: $e');
    }
  }
}
