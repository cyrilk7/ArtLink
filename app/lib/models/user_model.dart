class User {
  final String username;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String dob;
  final String email;
  final String gender;
  final String? password;
  final List<dynamic>? followers;
  final List<dynamic>? following;
  final List<dynamic>? posts;

  User({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.dob,
    required this.email,
    required this.gender,
    this.password,
    this.posts,
    this.followers,
    this.following,
  });

  // Convert User object to JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'dob': dob,
        'email': email,
        'gender': gender,
        'password': password,
      };

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        username: json['username'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        phoneNumber: json['phone_number'],
        dob: json['dob'],
        email: json['email'],
        gender: json['gender'],
        posts: json['posts'] ?? [],
        followers: json['followers'] ?? [],
        following: json['following'] ?? []);
  }
}
