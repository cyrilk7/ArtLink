import 'dart:async';

import 'package:ashlink/pages/sub_pages/landing_page.dart';
import 'package:ashlink/widgets/custom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    Timer(const Duration(seconds: 2), () async {
      if (token != null) {
        // User is logged in, navigate to CustomNavBar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomNavBar(
              initialIndex: 0,
            ),
          ),
        );
      } else {
        // User is not logged in, navigate to LandingPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LandingPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 70, 111, 201),
      body: Center(
        child: Text(
          'ArtLink',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
        ),
      ),
    );
  }
}
