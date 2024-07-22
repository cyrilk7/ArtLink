import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String label;
  final TextEditingController controller;
  final bool hideText;
  final bool? enabled;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.hideText = false,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.museoModerno(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity, // Takes up the full width of the screen
          decoration: BoxDecoration(
            color: const Color.fromARGB(
                255, 231, 231, 237), // Grey background color
            borderRadius:
                BorderRadius.circular(5), // Rounded corners (optional)
          ),
          child: TextField(
            enabled: enabled,
            obscureText: hideText,
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16.0),
              hintText: hintText,
              hintStyle:
                  TextStyle(color: Colors.grey[600]), // Placeholder text color
            ),
          ),
        ),
      ],
    );
  }
}
