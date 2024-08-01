import 'package:ashlink/pages/sub_pages/chat_page.dart';
import 'package:ashlink/pages/sub_pages/find_chat.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesPage extends StatefulWidget {
  final String username;
  final String email;
  const MessagesPage({super.key, required this.username, required this.email});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<Map<String, dynamic>> _chatRooms = [];
  final Map<String, Map<String, dynamic>> _usersCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getChatRoomsForUser(widget.username).then((_) {
      fetchUserDetails().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  Future<void> getChatRoomsForUser(String userId) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection("chat_rooms")
          .where("user_ids", arrayContains: userId)
          .get();

      // Sort the chat rooms by timestamp (descending order)
      setState(() {
        _chatRooms = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList()
          ..sort((a, b) {
            // Handle case where timestamp might be missing
            var timestampA = a['timestamp'] as Timestamp?;
            var timestampB = b['timestamp'] as Timestamp?;

            if (timestampA == null && timestampB == null) return 0;
            if (timestampA == null) return 1; // Treat null timestamps as older
            if (timestampB == null) return -1; // Treat null timestamps as older

            return timestampB.compareTo(timestampA); // Sort descending
          });
      });
    } catch (e) {
      print("Error fetching chat rooms: $e");
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      var userIds = _chatRooms
          .expand((room) => room['user_ids'] as List<dynamic>)
          .toSet();
      for (var userId in userIds) {
        if (!_usersCache.containsKey(userId)) {
          var docSnapshot = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

          if (docSnapshot.exists) {
            var userData = docSnapshot.data() as Map<String, dynamic>;
            _usersCache[userId] = userData;
          } else {
            print("User not found for username: $userId");
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                  ),
                ),
              ),
              CustomIconButton(
                buttonIcon: Icons.edit_note,
                onPressed: () {
                  
                },
              )
            ],
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                ),
              ),
            ),
            CustomIconButton(
              buttonIcon: Icons.edit_note,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindChatPage(
                      senderEmail: widget.email,
                      senderId: widget.username,
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
            Expanded(
              child: ListView.builder(
                itemCount: _chatRooms.length,
                itemBuilder: (context, index) {
                  var chatRoom = _chatRooms[index];
                  var lastMessage = chatRoom['last_message'] ?? 'No message';
                  var userIds = chatRoom['user_ids'] as List<dynamic>;
                  var otherUserId = userIds.firstWhere(
                      (id) => id != widget.username,
                      orElse: () => 'Unknown User');

                  var userData = _usersCache[otherUserId];
                  var userName = userData?['username'] ?? 'Unknown User';
                  var profileImageUrl = userData?['profile_image'] ?? '';

                  // Convert the timestamp to a DateTime object
                  var timestamp = (chatRoom['timestamp'] as Timestamp).toDate();

                  // Calculate the time ago
                  var timeAgo = timeago.format(timestamp);

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 29.0, // Set the desired size here
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl != ""
                              ? NetworkImage(profileImageUrl!)
                              : null, // Use profile image if available
                      child: profileImageUrl == null
                          ? Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 18),
                            )
                          : null, // Placeholder text if no profile image
                    ),
                    title: Text(userName),
                    subtitle: Text('$lastMessage - $timeAgo'),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            senderId: widget.username,
                            senderEmail: widget.email,
                            receiverUserEmail:
                                userData?['email'] ?? 'example@example.com',
                            receiverUserId: otherUserId,
                            phoneNumber: userData?['phone_number'] ?? "",
                            receiverName:
                                "${userData?['first_name']} ${userData?['last_name']}",
                          ),
                        ),
                      );

                      if (result) {
                        getChatRoomsForUser(widget.username).then((_) {
                          fetchUserDetails().then((_) {
                            setState(() {
                              _isLoading = false;
                            });
                          });
                        });
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
