import 'package:ashlink/pages/sub_pages/chat_page.dart';
import 'package:ashlink/services/chat_service.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/story_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  initState() {
    super.initState();

    // getClientMessages();
    getChatRoomsForUser("jadeeden");
  }

  getClientMessages() async {
    try {
      var data =
          await FirebaseFirestore.instance.collection("chat_rooms").get();

      setState(() {
        print("data ${data.docs}");
        // _allResults = data.docs;
      });
    } catch (e) {
      print("Error fetching chat rooms: $e");
    }
  }

  getChatRoomsForUser(String userId) async {
    try {
      // Query chat_rooms where user_ids array contains the specified userId
      var querySnapshot = await FirebaseFirestore.instance
          .collection("chat_rooms")
          .where("user_ids", arrayContains: userId)
          .get();

      setState(() {
        // Print the data for debugging purposes
        var docs = querySnapshot.docs.map((doc) => doc.data()).toList();
        print("Fetched chat rooms: $docs");
        // _allResults = querySnapshot.docs;
      });
    } catch (e) {
      print("Error fetching chat rooms: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final _chatService = ChatService();
    final currentUserId = 'jadeeden'; // Replace with the actual user ID

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(
                      receiverUserEmail: 'johndoe7@gmail.com',
                      receiverUserId: 'johndoe7',
                      phoneNumber: "0244610091", // Update if needed
                    ),
                  ),
                );
              },
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
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
