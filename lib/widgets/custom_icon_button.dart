import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData buttonIcon;
  final VoidCallback onPressed; // Callback function for dynamic behavior

  const CustomIconButton({
    Key? key,
    required this.buttonIcon,
    required this.onPressed, // Accept the callback function
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 0.5,
              blurRadius: 3,
              offset: const Offset(0, 3), // changes position of shadow (x, y)
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed, // Use the passed callback function
          icon: Icon(
            buttonIcon,
            size: 23,
            color: const Color.fromARGB(255, 70, 111, 201),
          ),
        ),
      ),
    );
  }
}
