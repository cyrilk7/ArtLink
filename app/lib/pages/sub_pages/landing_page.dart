import 'package:ashlink/pages/sub_pages/login.dart';
import 'package:ashlink/pages/sub_pages/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        centerTitle: false,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                //   decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.blueGrey, // Optional border color
                //     width: 2.0, // Optional border width
                //   ),
                // ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Image.asset("assets/icons/svg-icon.png"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Get Started',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 70, 111, 201),
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              'Where Artists Connect, Collaborate, and Create Beyond Boundaries',
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 70, 111, 201),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Border radius
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 13.0),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                          color: Colors.black, width: 2.0), // Border radius
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
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
