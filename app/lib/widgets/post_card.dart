import 'package:ashlink/controllers/post_controller.dart';
import 'package:ashlink/models/post_model.dart';
import 'package:ashlink/pages/main_pages/profile_page.dart';
import 'package:ashlink/pages/sub_pages/comment_page.dart';
import 'package:ashlink/pages/sub_pages/likes_page.dart';
import 'package:ashlink/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool? commentPost;
  const PostCard({super.key, required this.post, this.commentPost = false});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late int likeCount;
  PostController postController = PostController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Increased duration
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Smooth curve
      ),
    );
    isLiked = widget.post.isLiked;
    likeCount = widget.post.numLikes!;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> toggleLike(String postId) async {
    final count;
    try {
      if (isLiked) {
        count = await postController.unlikePost(postId);
        _animationController
            .forward()
            .then((_) => _animationController.reverse());
      } else {
        count = await postController.likePost(postId);
      }
      setState(() {
        isLiked = !isLiked;
        likeCount = count;
      });
    } catch (e) {
      // Handle error if necessary
      print('Error toggling follow status: $e');
    }
  }

  void openSMSAppWithMessage(String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '', // Leave path empty to not pre-fill any number
      queryParameters: <String, String>{'body': message},
    );

    // Check if the URL can be launched
    if (await canLaunchUrl(smsUri)) {
      // Launch the URL
      await launchUrl(smsUri);
    } else {
      throw 'Could not launch SMS app';
    }
  }

  void _shareRecipe(String postId) {
    String message =
        "Hey there! Checkout this post!\nhttps://europe-west2-level-ward-430511-k2.cloudfunctions.net/artlink-function-1/share_post/$postId";

    openSMSAppWithMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: !widget.commentPost!
            ? const Border(
                bottom: BorderSide(
                  color: Colors.grey, // Border color
                  width: 1, // Border width
                ),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: widget.commentPost! ? 0 : 12.0, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      username: widget.post.username,
                      thisUser: widget.post.thisUser,
                    ),
                  ),
                );
              },
              child: CustomAvatar(
                firstName: widget.post.firstName,
                imageUrl: widget.post.profileImage,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.post.firstName} ${widget.post.lastName}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${widget.post.username}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.more_horiz),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(widget.post.content),
                  const SizedBox(
                    height: 5,
                  ),
                  widget.post.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.post.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const SizedBox(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          toggleLike(widget.post.postId);
                        },
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: isLiked ? Colors.red : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LikesPage(
                                  postId: widget.post.postId,
                                ),
                              ),
                            );
                          },
                          child: Text('${likeCount.toString()} likes')),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CommentPage(postId: widget.post.postId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.comment_outlined),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.commentPost != null && !widget.commentPost!
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommentPage(postId: widget.post.postId),
                                  ),
                                )
                              : null;
                        },
                        child: Text(
                            '${widget.post.numComments.toString()} comments'),
                      ),
                      IconButton(
                        onPressed: () {
                          _shareRecipe(widget.post.postId);
                        },
                        icon: const Icon(Icons.share),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
