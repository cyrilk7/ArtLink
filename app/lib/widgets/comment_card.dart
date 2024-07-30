import 'package:ashlink/controllers/post_controller.dart';
import 'package:ashlink/models/comment_model.dart';
import 'package:ashlink/models/post_model.dart';
import 'package:ashlink/pages/main_pages/profile_page.dart';
import 'package:ashlink/pages/sub_pages/comment_page.dart';
import 'package:ashlink/pages/sub_pages/likes_page.dart';
import 'package:ashlink/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  const CommentCard({super.key, required this.comment});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<CommentCard>
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
    // print(widget.post.isLiked);
    isLiked = widget.comment.isLiked;
    likeCount = widget.comment.numLikes!;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> toggleLike(String commentId) async {
    final count;
    try {
      if (isLiked) {
        count = await postController.unlikeComment(commentId);
        _animationController
            .forward()
            .then((_) => _animationController.reverse());
      } else {
        count = await postController.likeComment(commentId);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Border color
            width: 1, // Border width
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      username: widget.comment.username,
                      thisUser: widget.comment.thisUser,
                    ),
                  ),
                );
              },
              child: CustomAvatar(
                firstName: widget.comment.firstName,
                imageUrl: widget.comment.profileImage,
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
                            '${widget.comment.firstName} ${widget.comment.lastName}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${widget.comment.username}',
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
                  Text(widget.comment.message),
                  const SizedBox(
                    height: 5,
                  ),
                  widget.comment.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.comment.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          toggleLike(widget.comment.commentId);
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => LikesPage(
                            //       postId: widget.comment.postId,
                            //     ),
                            //   ),
                            // );
                          },
                          child: Text('${likeCount.toString()} likes')),
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
