class Comment {
  final String commentId;
  final String username;
  final String firstName;
  final String lastName;
  final String message;
  final String? imageUrl;
  final String? profileImage;
  // final String timeAgo;
  final bool thisUser;
  final List<String>? likes;
  // final List<String>? comments;
  final int? numLikes;
  // final int? numComments;
  final bool isLiked;

  Comment({
    required this.commentId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.message,
    // required this.timeAgo,
    required this.thisUser,
    required this.isLiked,
    this.profileImage,
    this.imageUrl,
    // this.numComments,
    this.numLikes,
    this.likes,
    // this.comments
  });

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
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        commentId: json['comment_id'],
        username: json['username'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        message: json['message'],
        imageUrl: json['comment_image'],
        // timeAgo: json['time_ago'],
        profileImage: json["profile_image"],
        numLikes: json["likes"].length,
        // numComments: json["comments"].length,
        thisUser: json['this_user'],
        isLiked: json['isLiked']
        );
  }
}
