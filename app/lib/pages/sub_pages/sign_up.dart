import 'package:ashlink/pages/sub_pages/login.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
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
      body: SafeArea(
        minimum: EdgeInsets.only(bottom: 10),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              // height: MediaQuery.of(context).size.height * 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi!',
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
                    'Create a new account',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 70, 111, 201),
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'First name',
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
                    width: double
                        .infinity, // Takes up the full width of the screen
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 231, 231, 237), // Grey background color
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners (optional)
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16.0),
                        hintText: 'Jane',
                        hintStyle: TextStyle(
                            color: Colors.grey[600]), // Placeholder text color
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Last name',
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
                    width: double
                        .infinity, // Takes up the full width of the screen
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 231, 231, 237), // Grey background color
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners (optional)
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16.0),
                        hintText: 'Doe',
                        hintStyle: TextStyle(
                            color: Colors.grey[600]), // Placeholder text color
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Date of Birth',
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
                    width: double
                        .infinity, // Takes up the full width of the screen
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 231, 231, 237), // Grey background color
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners (optional)
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16.0),
                        hintText: 'yy-mm-dd',
                        hintStyle: TextStyle(
                            color: Colors.grey[600]), // Placeholder text color
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
                    width: double
                        .infinity, // Takes up the full width of the screen
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 231, 231, 237), // Grey background color
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners (optional)
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
                    height: 10,
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
                    width: double
                        .infinity, // Takes up the full width of the screen
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 231, 231, 237), // Grey background color
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners (optional)
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
                    height: 10,
                  ),
                  Text(
                    'Confirm Password',
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
                    width: double
                        .infinity, // Takes up the full width of the screen
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 231, 231, 237), // Grey background color
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners (optional)
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
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            const Color.fromARGB(255, 70, 111, 201),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Border radius
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
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(children: [
                        const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Log in ',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 70, 111, 201),
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to a new page or perform any action here
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                        ),
                      ]),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 20,
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
