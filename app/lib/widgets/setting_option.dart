import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingOption extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SettingOption({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: GoogleFonts.museoModerno(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Color.fromARGB(255, 70, 111, 201),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
