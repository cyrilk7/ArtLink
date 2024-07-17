import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // height: 100,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Column(
            children: [
              // const Align(
              //   alignment: Alignment.topRight,
              //   child: Text('just now'),
              // ),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cyril K',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            // color: Color.fromARGB(255, 70, 111, 201),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Text(
                        'Hey, how are you doing?',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            // color: Color.fromARGB(255, 70, 111, 201),
                            // fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
