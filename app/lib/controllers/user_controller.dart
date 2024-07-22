import 'dart:convert';

import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  final ApiService _apiService = ApiService();

  static final UserController _instance = UserController._internal();
  String? _token;

  factory UserController() {
    return _instance;
  }

  UserController._internal() {
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    _token = await _getToken();
  }

  Future<String?> _getToken() async {
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

  Future<String> loginUser(String username, String password) async {
    try {
      final response = await _apiService.post('login', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['success']) {
          return result['access_token'];
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

  Future<void> editUser(String firstName, String lastName, String email,
      String phoneNumber) async {
    try {
      final response = await _apiService.put(
          'edit_profile',
          {
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'phone_number': phoneNumber,
          },
          token: _token);

      if (!(response.statusCode == 200)) {
        var result = jsonDecode(response.body);
        throw Exception(result['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
