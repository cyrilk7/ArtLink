import 'package:flutter/material.dart';

class Notifications {
  final String message;
  final String timestamp;
  final String type;
  final String username;

  Notifications({
    required this.message,
    required this.timestamp,
    required this.type,
    required this.username,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      message: json['message'],
      timestamp: json['timestamp'],
      type: json['type'],
      username: json['username'],
    );
  }
}
