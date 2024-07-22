import 'package:ashlink/pages/sub_pages/landing_page.dart';
import 'package:ashlink/widgets/custom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

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
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
