import 'package:ashlink/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatService extends ChangeNotifier {
  final String senderId;
  final String senderEmail;

  ChatService({required this.senderId, required this.senderEmail});

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final Timestamp timestamp = Timestamp.now();

    // Create the new message object
    Message newMessage = Message(
        senderId: senderId,
        senderEmail: senderEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp);

    // Create chat room ID
    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Define the chat room document reference
    var chatRoomDocRef =
        FirebaseFirestore.instance.collection("chat_rooms").doc(chatRoomId);

    // Create the chat room data
    Map<String, dynamic> chatRoomData = {
      "user_ids": [senderId, receiverId],
      "last_message": message,
      "timestamp": timestamp,
    };

    // Add or update the chat room document
    await chatRoomDocRef.set(chatRoomData, SetOptions(merge: true));

    // Add the new message to the chat room's messages collection
    await chatRoomDocRef.collection('messages').add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<List<Message>> getAllChats(String userId) {
    return fireStore.collection("chat_rooms").snapshots().asyncMap(
      (snapshot) async {
        final chatRooms = snapshot.docs;
        print(chatRooms);
        List<Message> messages = [];

        for (var room in chatRooms) {
          final roomId = room.id;

          // Fetch the most recent message in this chat room
          final messagesQuery = await fireStore
              .collection("chat_rooms")
              .doc(roomId)
              .collection('messages')
              .orderBy('timestamp', descending: true) // Fetch most recent first
              .limit(1) // Limit to one document (the most recent message)
              .get();

          if (messagesQuery.docs.isNotEmpty) {
            final messageData = messagesQuery.docs.first.data();
            messages.add(Message.fromMap(messageData));
          }
        }

        return messages;
      },
    );
  }
}
