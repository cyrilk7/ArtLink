import 'package:ashlink/pages/sub_pages/messages.dart';
import 'package:ashlink/widgets/add_story.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/post_card.dart';
import 'package:ashlink/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ArtLink',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 70, 111, 201),
                  fontWeight: FontWeight.bold,
                  // fontSize: 22,
                ),
              ),
            ),
            CustomIconButton(
              buttonIcon: Icons.message,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MessagesPage()
                    ),
                  );
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 16.0, right: 0, top: 16, bottom: 16),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AddStoryCard(
                  profileImageUrl: 'assets/icons/test.png',
                  borderColor: Colors.grey,
                  borderWidth: 4.0,
                  whiteSpaceWidth: 4.0,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: SizedBox(
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
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            
            const PostCard(),
          ],
        ),
      ),
    );
  }
}
