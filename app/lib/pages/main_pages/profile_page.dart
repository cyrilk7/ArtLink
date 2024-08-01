import 'package:ashlink/controllers/user_controller.dart';
import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/pages/sub_pages/chat_page.dart';
import 'package:ashlink/pages/sub_pages/followers.dart';
import 'package:ashlink/pages/sub_pages/following_page.dart';
import 'package:ashlink/pages/sub_pages/profile_settings.dart';
import 'package:ashlink/widgets/custom_button.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/post_card.dart';
import 'package:ashlink/widgets/profile_stat.dart';
import 'package:ashlink/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the geolocator package

class LocationPermissionHandler {
  Future<void> requestLocationPermission() async {
    // Check if location permission is granted
    var status = await Permission.location.status;

    if (status.isGranted) {
      print('Location permission is already granted.');
    } else if (status.isDenied) {
      // Request location permission
      var result = await Permission.location.request();
      if (result.isGranted) {
        print('Location permission granted.');
      } else if (result.isDenied) {
        print('Location permission denied.');
      } else if (result.isPermanentlyDenied) {
        print(
            'Location permission permanently denied. Open settings to grant.');
        // openAppSettings();
      }
    } else if (status.isPermanentlyDenied) {
      // Open app settings for the user to grant permission
      // openAppSettings();
    }
  }
}

class ProfilePage extends StatefulWidget {
  final String? username;
  final bool thisUser;

  const ProfilePage({super.key, this.username, this.thisUser = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> userProfileFuture;
  bool isFollowing = false;
  bool isInitialLoad = true;
  UserController userController = UserController();
  String? currentUsername;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    if (!widget.thisUser) {
      getCurrentUser();
    } else {
      userProfileFuture = _fetchUserProfile();
    }
  }

  Future<void> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? '';
      currentUserEmail = prefs.getString('email') ?? '';
    });
    userProfileFuture = _fetchUserProfile();
  }

  Future<User> _fetchUserProfile() async {
    await userController.initializeToken();
    User user;
    if (widget.username != null) {
      user = await userController.getUserProfileById(widget.username!);
    } else {
      user = await userController.getUserProfile();
    }
    setState(() {
      isFollowing = user.isFollowing ?? false;
    });
    return user;
  }

  Future<void> toggleFollow(String username) async {
    try {
      if (isFollowing) {
        await userController.unfollowUser(username);
      } else {
        await userController.followUser(username);
      }
      setState(() {
        isFollowing = !isFollowing;
        userProfileFuture = _fetchUserProfile();
        isInitialLoad = false;
      });
    } catch (e) {
      print('Error toggling follow status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: FutureBuilder<User>(
        future: userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              isInitialLoad) {
            return const Scaffold(
              backgroundColor: Color.fromARGB(255, 248, 248, 248),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 248, 248, 248),
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 248, 248, 248),
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 248, 248, 248),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.museoModerno(
                        textStyle: const TextStyle(
                          color: Color.fromARGB(255, 70, 111, 201),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    widget.thisUser
                        ? CustomIconButton(
                            buttonIcon: Icons.settings,
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileSettings(
                                          user: user,
                                        )),
                              );

                              if (result == true) {
                                setState(() {
                                  userProfileFuture =
                                      userController.getUserProfile();
                                });
                              }
                            },
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: UserAvatar(
                      userName: user.firstName,
                      imageUrl: user.profileImage,
                    )),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "${user.firstName} ${user.lastName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Color.fromARGB(255, 70, 111, 201),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            user.location!, // Display the city here
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ProfileStat(
                              count: user.posts!.length.toString(),
                              label: 'Posts'),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FollowersPage(username: user.username),
                                ),
                              );
                            },
                            child: ProfileStat(
                                count: user.followers!.length.toString(),
                                label: 'Followers'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FollowingPage(username: user.username),
                                ),
                              );
                            },
                            child: ProfileStat(
                                count: user.following!.length.toString(),
                                label: 'Following'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    !widget.thisUser
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                onPressed: () {
                                  toggleFollow(widget.username!);
                                },
                                text:
                                    user.isFollowing! ? 'Following' : 'Follow',
                                width: 160,
                                backgroundColor: !(user.isFollowing!)
                                    ? const Color.fromARGB(255, 70, 111, 201)
                                    : Colors.white,
                                borderColor:
                                    user.isFollowing! ? Colors.black : null,
                                textColor: !(user.isFollowing)!
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              CustomButton(
                                onPressed: () {
                                  currentUserEmail != null &&
                                          currentUsername != null
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              senderId: currentUsername!,
                                              senderEmail: currentUserEmail!,
                                              receiverUserEmail: user.email ??
                                                  'example@example.com',
                                              receiverUserId: user.username,
                                              phoneNumber:
                                                  user.phoneNumber ?? "",
                                              receiverName:
                                                  "${user.firstName} ${user.lastName}",
                                            ),
                                          ),
                                        )
                                      : null;
                                },
                                text: 'Message',
                                width: 160,
                                borderColor: Colors.black,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.thisUser ? 'Your posts' : 'Posts',
                        style: GoogleFonts.museoModerno(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 2,
                      color: const Color.fromARGB(255, 184, 184, 184),
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: user.posts!.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: user.posts![index]);
                        }),
                  ],
                ),
              ),
            );
          } else {
            return const Scaffold(
              backgroundColor: Color.fromARGB(255, 248, 248, 248),
              body: Center(child: Text('No data available')),
            );
          }
        },
      ),
    );
  }
}
