import 'package:ashlink/widgets/MESSAGE_card.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        leading: CustomIconButton(
          buttonIcon: Icons.arrow_back,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chats',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 70, 111, 201),
                  fontWeight: FontWeight.bold,
                  // fontSize: 22,
                ),
              ),
            ),
            CustomIconButton(
              buttonIcon: Icons.edit_note,
              onPressed: () {},
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search chats here...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Quick chats',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  // fontSize: 22,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 70,
              // width: 120,
              child: ListView.builder(
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return const Row(
                    children: [
                      StoryCard(
                        profileImageUrl: 'assets/icons/test.png',
                        borderColor: Color.fromARGB(255, 70, 111, 201),
                        borderWidth: 4.0,
                        whiteSpaceWidth: 4.0,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Messages',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  // fontSize: 22,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const MessageCard(),
          ],
        ),
      ),
    );
  }
}
