import 'package:flutter/material.dart';

class AddStoryCard extends StatelessWidget {
  final String profileImageUrl;
  final Color borderColor;
  final double borderWidth;
  final double whiteSpaceWidth;

  const AddStoryCard({
    super.key,
    required this.profileImageUrl,
    required this.borderColor,
    required this.borderWidth,
    required this.whiteSpaceWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Colored border
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 50 + (2 * borderWidth) + (2 * whiteSpaceWidth),
            height: 50 + (2 * borderWidth) + (2 * whiteSpaceWidth),
            color: borderColor,
          ),
        ),
        // White space
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 50 + (2 * whiteSpaceWidth),
            height: 50 + (2 * whiteSpaceWidth),
            color: Colors.white,
          ),
        ),
        // Profile image
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const SizedBox(
            width: 50,
            height: 50,
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}