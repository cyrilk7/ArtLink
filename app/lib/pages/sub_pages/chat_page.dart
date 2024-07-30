import 'package:ashlink/services/chat_service.dart';
import 'package:ashlink/widgets/chat_bubble.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  final String phoneNumber;

  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserId,
      required this.phoneNumber});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final _chatService = ChatService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserId, _messageController.text);

      _messageController.clear();
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Handle the error if the phone call cannot be initiated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not make the call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100), // Adjust height as needed
          child: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIconButton(
                  buttonIcon: Icons.arrow_back,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20, // Replace with your image
                      ),
                      SizedBox(height: 4),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle overflow
                      ),
                    ],
                  ),
                ),
                CustomIconButton(
                  buttonIcon: Icons.call,
                  onPressed: () {
                    _makePhoneCall(widget.phoneNumber);
                  },
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildMessageInput(),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ));
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserId, "jadeeden"),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == 'jadeeden'
        ? Alignment.centerRight
        : Alignment.centerLeft);

    var textColor =
        (data['senderId'] == 'jadeeden' ? Colors.white : Colors.black);

    var bubbleColor = (data['senderId'] == 'jadeeden'
        ? const Color.fromARGB(255, 70, 111, 201)
        : const Color.fromARGB(255, 231, 231, 237));

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == 'jadeeden')
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            const SizedBox(
              height: 5,
            ),
            ChatBubble(
              message: data['message'],
              textColor: textColor,
              bubbleColor: bubbleColor,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextFormField(
      controller: _messageController,
      decoration: InputDecoration(
        hintText: 'Enter message',
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: GestureDetector(
          onTap: sendMessage,
          child: Icon(Icons.send, color: Colors.grey[600]),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      ),
    );
  }
}
