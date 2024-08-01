import 'package:ashlink/models/post_model.dart';

class User {
  final String username;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? dob;
  final String? email;
  final String? gender;
  final String? password;
  final List<dynamic>? followers;
  final List<dynamic>? following;
  final List<Post>? posts;
  bool? isFollowing;
  final String? profileImage;
  String? location;
  final bool? thisUser;

  User(
      {required this.username,
      required this.firstName,
      required this.lastName,
      this.phoneNumber,
      this.dob,
      this.email,
      this.gender,
      this.profileImage,
      this.password,
      this.posts,
      this.followers,
      this.following,
      this.isFollowing,
      this.thisUser,
      this.location});

  // Convert User object to JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'dob': dob,
        'email': email,
        'gender': gender,
        'location': location,
        'password': password,
      };

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    List<dynamic> postsJson = json['posts'] ?? [];
    List<Post> posts =
        postsJson.map((postJson) => Post.fromJson(postJson)).toList();
    return User(
        username: json['username'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        phoneNumber: json['phone_number'],
        location: json['location'],
        dob: json['dob'],
        email: json['email'],
        gender: json['gender'],
        posts: posts,
        followers: json['followers'] ?? [],
        following: json['following'] ?? [],
        isFollowing: json['isFollowing'] ?? false,
        thisUser: json['this_user'] ?? false,
        profileImage: json['profile_image']);
  }
}
