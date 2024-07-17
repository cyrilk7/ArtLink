import 'package:ashlink/pages/sub_pages/sign_up.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/custom_nav_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
            Text(
              'Email',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity, // Takes up the full width of the screen
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 231, 231, 237), // Grey background color
                borderRadius:
                    BorderRadius.circular(5), // Rounded corners (optional)
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                  hintText: 'jane.doe@gmail.com',
                  hintStyle: TextStyle(
                      color: Colors.grey[600]), // Placeholder text color
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Password',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity, // Takes up the full width of the screen
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 231, 231, 237), // Grey background color
                borderRadius:
                    BorderRadius.circular(5), // Rounded corners (optional)
              ),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                  hintText: '********',
                  hintStyle: TextStyle(
                      color: Colors.grey[600]), // Placeholder text color
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Is this right?
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomNavBar(
                        initialIndex: 0,
                      ),
                    ),
                  );
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
