import 'dart:io';
import 'package:ashlink/controllers/post_controller.dart';
import 'package:ashlink/models/post_model.dart';
import 'package:ashlink/widgets/comment_card.dart';
import 'package:ashlink/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  const CommentPage({super.key, required this.postId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage>
    with SingleTickerProviderStateMixin {
  PostController postController = PostController();
  final TextEditingController _controller = TextEditingController();
  File? _postImage;
  bool isInitialLoad = true;
  bool postButtonEnabled = false;

  Future<Post> _fetchPost() async {
    return await postController.getPostById(widget.postId);
  }

  void _postComment(String postId) async {
    final content = _controller.text;
    try {
      if (content.isNotEmpty) {
        await postController.createComment(postId, content, _postImage);
        _controller.clear();
        setState(() {
          isInitialLoad = false;
          _fetchPost();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        title: Text(
          'ArtLink',
          style: GoogleFonts.museoModerno(
            textStyle: const TextStyle(
              color: Color.fromARGB(255, 70, 111, 201),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Colors.grey[400]!, width: 1.0), // Grey bottom border
            ),
          ),
        ),
      ),
      body: FutureBuilder(
          future: _fetchPost(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && isInitialLoad) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No post data available.'));
            } else {
              final post = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: PostCard(
                              post: post,
                              commentPost: true,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Colors.grey,
                          ),
                          if (post.commentObjs != null &&
                              post.commentObjs!.isNotEmpty)
                            Column(
                              children: post.commentObjs!
                                  .map((comment) => Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: CommentCard(comment: comment),
                                      ))
                                  .toList(),
                            )
                          else ...[
                            const SizedBox(
                              height: 20,
                            ),
                            const Center(child: Text('No comments available.')),
                          ]
                        ],
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildMessageInput()),
                  const SizedBox(
                    height: 20,
                  )
                ],
              );
            }
          }),
    );
  }

  Widget _buildMessageInput() {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Enter comment',
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: GestureDetector(
          onTap: () {
            _postComment(widget.postId);
          },
          child: Icon(Icons.send, color: Colors.grey[600]),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      ),
    );
  }
}
