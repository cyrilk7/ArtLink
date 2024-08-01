import 'package:ashlink/controllers/user_controller.dart';
import 'package:ashlink/pages/sub_pages/sign_up.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/custom_nav_bar.dart';
import 'package:ashlink/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final UserController _userController = UserController();
  String _errorMessage = '';

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    Tuple3<String, String, String> result;

    try {
      result = await UserController().loginUser(username, password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', result.item1);
      await prefs.setString('username', result.item2);
      await prefs.setString('email', result.item3);


      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomNavBar(
            initialIndex: 0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        leadingWidth: 65,
        leading: CustomIconButton(
          buttonIcon: Icons.arrow_back,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  // color: Color.fromARGB(255, 70, 111, 201),
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Sign in to continue',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 70, 111, 201),
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            CustomTextField(
              label: 'Username',
              hintText: 'janedoe7',
              controller: _usernameController,
            ),
            const SizedBox(
              height: 30,
            ),
            CustomTextField(
              hideText: true,
              label: 'Password',
              hintText: '********',
              controller: _passwordController,
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _login();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 70, 111, 201),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Border radius
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 13.0),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(children: [
                  const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Sign up ',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 70, 111, 201),
                        fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigate to a new page or perform any action here
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                  ),
                ]),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
