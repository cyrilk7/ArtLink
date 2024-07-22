import 'package:ashlink/controllers/user_controller.dart';
import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/pages/sub_pages/profile_settings.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/profile_stat.dart';
import 'package:ashlink/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final userController = UserController();

    return FutureBuilder<User>(
      future: userController.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
                  CustomIconButton(
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
                          userController.getUserProfile();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: UserAvatar(userName: user.firstName)),
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
                const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: Color.fromARGB(255, 70, 111, 201),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'London',
                        style: TextStyle(fontSize: 16),
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
                          count: user.posts!.length.toString(), label: 'Posts'),
                      ProfileStat(
                          count: user.followers!.length.toString(),
                          label: 'Followers'),
                      ProfileStat(
                          count: user.following!.length.toString(),
                          label: 'Following'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Your posts',
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
              ],
            ),
          );
        } else {
          return const Scaffold(
            backgroundColor: Color.fromARGB(255, 248, 248, 248),
            body: Center(child: Text('No data available')),
          );
        }
      },
    );
  }
}
