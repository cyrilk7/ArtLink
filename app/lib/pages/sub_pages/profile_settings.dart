import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/pages/sub_pages/edit_profile.dart';
import 'package:ashlink/widgets/custom_button.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/setting_option.dart';
import 'package:ashlink/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSettings extends StatelessWidget {
  final User user;

  const ProfileSettings({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        leading: CustomIconButton(
          buttonIcon: Icons.arrow_back,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.museoModerno(
            textStyle: const TextStyle(
              color: Color.fromARGB(255, 70, 111, 201),
              fontWeight: FontWeight.bold,
              // fontSize: 22,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Center(child: UserAvatar(userName: user.firstName, imageUrl: user.profileImage,)),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              '@${user.username}',
              style: const TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Center(
            child: Text(
              "${user.firstName} ${user.lastName}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          SettingOption(
            text: 'Edit Profile',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(
                    user: user,
                  ),
                ),
              );

              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
          const SizedBox(
            height: 25,
          ),
          SettingOption(
            text: 'Log out',
            onTap: () {},
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: CustomButton(
              onPressed: () {
                Navigator.pop(context);
              },
              text: 'Back',
              backgroundColor: const Color.fromARGB(255, 70, 111, 201),
            ),
          )
        ],
      ),
    );
  }
}
