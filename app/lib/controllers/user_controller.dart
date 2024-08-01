import 'dart:convert';
import 'dart:io';

import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class UserController {
  static final UserController _instance = UserController._internal();
  factory UserController() => _instance;
  UserController._internal();

  final ApiService _apiService = ApiService();

  String? _token;

  Future<void> initializeToken() async {
    _token = await getToken();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String> registerUser(User user) async {
    try {
      final response = await _apiService.post('users', user.toJson());

      if (response.statusCode == 201) {
        return response.body;
      } else {
        var result = jsonDecode(response.body);
        throw Exception(result["message"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Tuple3<String, String, String>> loginUser(
      String username, String password) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    try {
      final response = await _apiService.post('login', {
        'username': username,
        'password': password,
        'fcmToken': fcmToken,
      });

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['success']) {
          return Tuple3(result['access_token'], result['username'], result["email"]);
        } else {
          throw Exception(result['message']);
        }
      } else {
        var result = jsonDecode(response.body);
        throw Exception(result['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User> getUserProfile() async {
    final response = await _apiService.get('view_profile', token: _token);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      User user = User.fromJson(jsonData);
      return user;
    } else {
      throw Exception(
          'Failed to load user. Status code: ${response.statusCode}');
    }
  }

  Future<User> getUserProfileById(String username) async {
    final response =
        await _apiService.get('view_profile/$username', token: _token);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      User user = User.fromJson(jsonData);
      return user;
    } else {
      throw Exception(
          'Failed to load user. Status code: ${response.statusCode}');
    }
  }


  Future<List<User>> getUserFollowing(String username) async {
    final response =
        await _apiService.get('following/$username', token: _token);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<User> users = jsonData.map((data) => User.fromJson(data)).toList();
      return users;
    } else {
      throw Exception(
          'Failed to load users. Status code: ${response.statusCode}');
    }
  }

  Future<List<User>> getUserFollowers(String username) async {
    final response =
        await _apiService.get('followers/$username', token: _token);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<User> users = jsonData.map((data) => User.fromJson(data)).toList();
      return users;
    } else {
      throw Exception(
          'Failed to load users. Status code: ${response.statusCode}');
    }
  }
  
  Future<void> editUser(String firstName, String lastName, String email,
      String phoneNumber, File? profileImage) async {
    try {
      final response = await _apiService.putImg(
        '/edit_profile',
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phoneNumber,
        },
        file: profileImage,
        token: _token,
        requiresAuth: true, // Specify that this request requires authentication
      );
      if (!(response.statusCode == 200)) {
        var result = jsonDecode(response.body);
        throw Exception(result['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> followUser(String username) async {
    final response = await _apiService.post(
      'follow_user',
      {'username': username},
      token: _token,
    );

    var result = jsonDecode(response.body);
    if (!result["success"]) {
      throw Exception(result["message"]);
    }
  }

  Future<void> unfollowUser(String username) async {
    final response = await _apiService.post(
      'unfollow_user',
      {'username': username},
      token: _token,
    );

    var result = jsonDecode(response.body);
    if (!result["success"]) {
      throw Exception(result["message"]);
    }
  }
}
