
import 'package:ashlink/controllers/user_controller.dart';
import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/pages/main_pages/profile_page.dart';
import 'package:ashlink/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FollowingPage extends StatefulWidget {
  final String username;

  const FollowingPage({super.key, required this.username});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  late Future<List<User>> followingFuture;
  // final postController = PostController();
  final userController = UserController();
  // bool isRefeshed = false;

  @override
  void initState() {
    super.initState();
    followingFuture = userController.getUserFollowing(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        title: Text(
          'ArtLink',
          style: GoogleFonts.museoModerno(
            textStyle: const TextStyle(
              color: Color.fromARGB(255, 70, 111, 201),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
          ),
        
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: followingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Not following anyone yet.'),
                  );
                } else {
                  List<User> userList = snapshot.data!;

                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      final user = userList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                username: user.username,
                                thisUser: user.thisUser!,
                              ),
                            ),
                          ).then((_) {
                            setState(() {
                              followingFuture =
                                  userController.getUserFollowing(widget.username);
                            });
                          });

                          // .then((_)=>setState(()=>{}));
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 29.0, // Set the desired size here
                            backgroundImage: user.profileImage != null
                                ? NetworkImage(user.profileImage!)
                                : null, // Use profile image if available
                            child: user.profileImage == null
                                ? Text(
                                    user.username[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 18),
                                  )
                                : null, // Placeholder text if no profile image
                          ),
                          title: Text(user.username),
                          subtitle: Text(user.firstName),
                          trailing: !(user.thisUser!)
                              ? CustomButton(
                                  paddingHorizontal: 0,
                                  paddingVertical: 5,
                                  onPressed: () {
                                    // if (!user.isFollowing!) {
                                    //   followUser(user);
                                    // } else {
                                    //   print("Already following");
                                    // }
                                  },
                                  text: user.isFollowing!
                                      ? 'Following'
                                      : 'Follow',
                                  width: 100,
                                  backgroundColor: !(user.isFollowing!)
                                      ? const Color.fromARGB(255, 70, 111, 201)
                                      : Colors.white,
                                  borderColor:
                                      user.isFollowing! ? Colors.black : null,
                                  textColor: !(user.isFollowing)!
                                      ? Colors.white
                                      : Colors.black,
                                )
                              : const SizedBox(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
