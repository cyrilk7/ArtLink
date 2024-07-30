import 'dart:convert';
import 'dart:io';

import 'package:ashlink/models/post_model.dart';
import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostController {
  final ApiService _apiService = ApiService();
  static final PostController _instance = PostController._internal();
  String? _token;

  factory PostController() {
    return _instance;
  }

  PostController._internal() {
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    _token = await _getToken();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> createPost(
    String content,
    File? imageFile,
  ) async {
    final response = await _apiService.postImg(
      '/create_post',
      body: {'content': content},
      file: imageFile,
      token: _token,
      requiresAuth: true, // Specify that this request requires authentication
    );

    var result = jsonDecode(response.body);
    if (response.statusCode == 201) {
    } else {
      throw Exception(result['error']);
    }
  }

  Future<void> createComment(
    String postId,
    String message,
    File? imageFile,
  ) async {
    final response = await _apiService.postImg(
      '/create_comment',
      body: {'post_id': postId, 'message': message},
      file: imageFile,
      token: _token,
      requiresAuth: true, // Specify that this request requires authentication
    );

    var result = jsonDecode(response.body);
    if (response.statusCode == 201) {
    } else {
      throw Exception(result['error']);
    }
  }

  Future<List<Post>> getAllPosts() async {
    final response = await _apiService.get('posts', token: _token);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Post> posts = jsonData.map((data) => Post.fromJson(data)).toList();
      return posts;
    } else {
      throw Exception(
          'Failed to load user. Status code: ${response.statusCode}');
    }
  }

  Future<List<Post>> getFollowingPosts() async {
    final response = await _apiService.get('posts/following', token: _token);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Post> posts = jsonData.map((data) => Post.fromJson(data)).toList();
      return posts;
    } else {
      throw Exception(
          'Failed to load user. Status code: ${response.statusCode}');
    }
  }

  Future<List<User>> getPostLikes(String postId) async {
    final response =
        await _apiService.get('posts/likes/$postId', token: _token);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<User> users = jsonData.map((data) => User.fromJson(data)).toList();
      return users;
    } else {
      throw Exception(
          'Failed to load likes. Status code: ${response.statusCode}');
    }
  }

  Future<Post> getPostById(String postId) async {
    final response = await _apiService.get('posts/$postId', token: _token);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      Post post = Post.fromJson(jsonData);
      return post;
    } 
    else {
      throw Exception(
          'Failed to load post. Status code: ${response.statusCode}');
    }
  }

  Future<int> likePost(String postId) async {
    final response = await _apiService.post(
      'like_post',
      {'post_id': postId},
      token: _token,
    );

    var result = jsonDecode(response.body);
    if (!result["success"]) {
      throw Exception(result["message"]);
    } else {
      return result['count'];
    }
  }

  Future<int> unlikePost(String postId) async {
    final response = await _apiService.post(
      'unlike_post',
      {'post_id': postId},
      token: _token,
    );

    var result = jsonDecode(response.body);
    if (!result["success"]) {
      throw Exception(result["message"]);
    } else {
      return result['count'];
    }
  }

  Future<int> likeComment(String commentId) async {
    final response = await _apiService.post(
      'like_comment',
      {'comment_id': commentId},
      token: _token,
    );

    var result = jsonDecode(response.body);
    if (!result["success"]) {
      throw Exception(result["message"]);
    } else {
      return result['count'];
    }
  }

  Future<int> unlikeComment(String commentId) async {
    final response = await _apiService.post(
      'unlike_comment',
      {'comment_id': commentId},
      token: _token,
    );

    var result = jsonDecode(response.body);
    if (!result["success"]) {
      throw Exception(result["message"]);
    } else {
      return result['count'];
    }
  }
}
