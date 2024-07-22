import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStat extends StatelessWidget {
  final String count;
  final String label;
  final VoidCallback? onTap;

  const ProfileStat({
    super.key,
    required this.count,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
