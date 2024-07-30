import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl; // User image URL
  final String firstName;
  final double? radius; 

  const CustomAvatar({
    super.key,
    this.imageUrl,
    required this.firstName,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      // radius: 30, // Set the radius of the CircleAvatar
      backgroundColor: imageUrl == null || imageUrl!.isEmpty
          ? Colors.grey // Grey background if no image
          : Colors.transparent, // Transparent if image is available
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!) // Set image from URL
          : null, // No image if URL is null or empty
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              _getInitials(firstName), // Display initials if no image
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          : null, // No text if image is available
    );
  }

  // Function to get initials from the first name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.isEmpty) return '';
    return names.first[0].toUpperCase();
  }
}
