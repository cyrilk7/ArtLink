import 'package:ashlink/models/comment_model.dart';

class Post {
  final String postId;
  final String username;
  final String firstName;
  final String lastName;
  final String content;
  final String? imageUrl;
  final String? profileImage;
  final String timeAgo;
  final bool thisUser;
  final List<String>? likes;
  final List<String>? comments;
  final int? numLikes;
  final int? numComments;
  final bool isLiked;
  final List<Comment>? commentObjs;

  Post(
      {required this.postId,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.content,
      required this.timeAgo,
      required this.thisUser,
      required this.isLiked,
      this.profileImage,
      this.commentObjs,
      this.imageUrl,
      this.numComments,
      this.numLikes,
      this.likes,
      this.comments});

  // Map<String, dynamic> toJson() => {
  //       'username': username,
  //       'first_name': firstName,
  //       'last_name': lastName,
  //       'phone_number': phoneNumber,
  //       'dob': dob,
  //       'email': email,
  //       'gender': gender,
  //       'password': password,
  //     };

  // // Convert JSON to User object
  factory Post.fromJson(Map<String, dynamic> json) {
    List<dynamic> commentsJson = json["comment_obj"] ?? [];
    List<Comment> comments =
        commentsJson.map((data) => Comment.fromJson(data)).toList();
    return Post(
      postId: json['post_id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      content: json['content'],
      imageUrl: json['image_url'],
      timeAgo: json['time_ago'],
      profileImage: json["profile_image"],
      numLikes: json["likes"].length,
      numComments: json["comments"].length,
      thisUser: json['this_user'],
      isLiked: json['isLiked'],
      commentObjs: comments,
    );
  }
}
