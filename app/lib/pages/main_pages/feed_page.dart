import 'package:ashlink/controllers/post_controller.dart';
import 'package:ashlink/models/post_model.dart';
import 'package:ashlink/pages/main_pages/create_page.dart';
import 'package:ashlink/pages/sub_pages/create_post.dart';
import 'package:ashlink/pages/sub_pages/messages.dart';
import 'package:ashlink/widgets/add_story.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/post_card.dart';
import 'package:ashlink/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late String selectedOption;
  late Future<List<Post>> postsFuture;
  final _postController = PostController();

  void updateSelectedOption(String option) {
    setState(() {
      selectedOption = option;
      postsFuture = fetchPosts();
    });
  }

  @override
  void initState() {
    super.initState();
    selectedOption = 'All';
    postsFuture = fetchPosts();
  }

  Future<List<Post>> fetchPosts() {
    if (selectedOption == 'All') {
      return _postController.getAllPosts();
    } else {
      return _postController.getFollowingPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ArtLink',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 70, 111, 201),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomIconButton(
              buttonIcon: Icons.message,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesPage()),
                );
              },
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 0.0, right: 0, top: 0, bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildOption('All'),
                    buildOption('Following'),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: double.infinity,
                  color: Colors.grey,
                  height: 1,
                ),
                Expanded(
                  child: FutureBuilder<List<Post>>(
                    future: postsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No posts available.'),
                        );
                      } else {
                        final posts = snapshot.data!;
                        return ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: PostCard(
                                post: post,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePost(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    selectedOption = 'All';
                    postsFuture = fetchPosts();
                  });
                }
              },
              backgroundColor: const Color.fromARGB(255, 70, 111, 201),
              child: const Icon(
                color: Colors.white,
                Icons.add,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOption(String option) {
    bool isSelected = selectedOption == option;
    return GestureDetector(
      onTap: () => updateSelectedOption(option),
      child: Column(
        children: [
          Text(
            option,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? const Color.fromARGB(255, 70, 111, 201)
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 1.0), // Spacer between text and underline
          Container(
            width: 50.0,
            height: 2.0,
            color: isSelected
                ? const Color.fromARGB(255, 70, 111, 201)
                : const Color.fromARGB(255, 248, 248, 248),
          ),
        ],
      ),
    );
  }
}
