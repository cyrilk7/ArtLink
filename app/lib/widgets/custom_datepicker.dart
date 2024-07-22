import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDatepicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function()? onTap;

  const CustomDatepicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
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
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 231, 231, 237),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              selectedDate == null
                  ? 'yy-mm-dd'
                  : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
              style: TextStyle(
                color: selectedDate == null ? Colors.grey[600] : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
