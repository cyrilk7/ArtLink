import 'package:ashlink/controllers/post_controller.dart';
import 'package:ashlink/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // for jsonDecode
import 'package:http/http.dart' as http; // for http requests

// Define your Notifications model and getNotifications function here

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Notifications>> _notifications;
  final _postController = PostController();

  @override
  void initState() {
    super.initState();
    _notifications = _postController.getNotifications();
  }

  // Future<List<Notifications>> getNotifications() async {
  //   final response =
  //       await http.get(Uri.parse('YOUR_API_URL/notifications'), headers: {'Authorization': 'Bearer YOUR_TOKEN'});

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonData = jsonDecode(response.body);
  //     List<Notifications> notifications = jsonData.map((data) => Notifications.fromJson(data)).toList();
  //     return notifications;
  //   } else {
  //     throw Exception('Failed to load notifications. Status code: ${response.statusCode}');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 248, 248, 248),
        title: Text('Notifications'),
      ),
      body: FutureBuilder<List<Notifications>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications available.'));
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: _getLeadingIcon(notification.type),
                  title: Text(notification.message),
                  // subtitle: Text(timeAgo(notification.timestamp)),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _getLeadingIcon(String type) {
    switch (type) {
      case 'follow':
        return Icon(Icons.person_add, color: Colors.blue);
      case 'like':
        return Icon(Icons.thumb_up, color: Colors.green);
      default:
        return SizedBox.shrink(); // Empty widget if no matching type
    }
  }

  String timeAgo(DateTime postTimestamp) {
    final now = DateTime.now().toUtc();
    final elapsedTime = now.difference(postTimestamp);
    final seconds = elapsedTime.inSeconds;

    if (seconds < 60) {
      return '$seconds secs';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '$minutes mins';
    } else if (seconds < 86400) {
      final hours = seconds ~/ 3600;
      return '$hours hrs';
    } else {
      final days = seconds ~/ 86400;
      return '$days days';
    }
  }
}
