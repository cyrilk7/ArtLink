import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String userName;

  const UserAvatar({super.key, this.imageUrl, required this.userName});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 60.0, // Adjust the size as needed
      backgroundColor: Colors.grey[200],
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '',
              style: const TextStyle(fontSize: 40.0, color: Colors.black), // Adjust the font size as needed
            )
          : null,
    );
  }
}