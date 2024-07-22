import 'dart:convert';

import 'package:ashlink/controllers/user_controller.dart';
import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/pages/sub_pages/login.dart';
import 'package:ashlink/widgets/custom_alert.dart';
import 'package:ashlink/widgets/custom_button.dart';
import 'package:ashlink/widgets/custom_datepicker.dart';
import 'package:ashlink/widgets/custom_dropdown.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  DateTime? selectedDate;
  final List<String> genders = ['Male', 'Female'];
  String? _gender;

  final UserController _userController = UserController();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isPhoneNumberValid(String phoneNumber) {
    final RegExp phoneRegExp = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  bool isEmailValid(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }

  bool allFieldsFilled() {
    return _usernameController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        selectedDate != null &&
        _gender != null;
  }

  bool validateFields() {
    if (!allFieldsFilled()) {
      showDialog(
        context: context,
        builder: (ctx) => CustomAlertDialog(
            title: 'Missing fields',
            content: 'Make sure to fill out all fields',
            onConfirm: Navigator.of(ctx).pop),
      );
      return false;
    }

    if (!isEmailValid(_emailController.text)) {
      showDialog(
        context: context,
        builder: (ctx) => CustomAlertDialog(
            title: 'Invalid',
            content: 'Make sure to enter a valid email',
            onConfirm: Navigator.of(ctx).pop),
      );
      return false;
    }

    if (!isPhoneNumberValid(_phoneNumberController.text)) {
      showDialog(
        context: context,
        builder: (ctx) => CustomAlertDialog(
            title: 'Invalid',
            content: 'Make sure to enter a valid phone number',
            onConfirm: Navigator.of(ctx).pop),
      );
      return false;
    }
    return true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1915, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _registerUser() async {
    try {
      if (validateFields()) {
        User user = User(
          username: _usernameController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneNumberController.text,
          dob: DateFormat('yyyy-MM-dd').format(selectedDate!),
          email: _emailController.text,
          gender: _gender!,
          password: _passwordController.text,
        );

        await _userController.registerUser(user);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => CustomAlertDialog(
            title: 'An error occured',
            content: e.toString(),
            onConfirm: Navigator.of(ctx).pop),
      );
      
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
        minimum: const EdgeInsets.only(bottom: 10),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
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
                  CustomTextField(
                    label: 'First name',
                    hintText: 'Jane',
                    controller: _firstNameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    label: 'Last name',
                    hintText: 'Doe',
                    controller: _lastNameController,
                  ),
                  CustomDatepicker(
                    label: 'Date of Birth',
                    selectedDate: selectedDate,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomDropdown(
                    label: 'Gender',
                    value: _gender,
                    items: genders,
                    onChanged: (newValue) {
                      setState(() {
                        _gender = newValue;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                      label: 'Email',
                      hintText: 'jane.doe@gmail.com',
                      controller: _emailController),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    label: ' Phone number',
                    hintText: '+233 0000000',
                    controller: _phoneNumberController,
                  ),
                  CustomTextField(
                    label: 'Username',
                    hintText: 'janedoe10',
                    controller: _usernameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    hideText: true,
                    label: 'Password',
                    hintText: '******',
                    controller: _passwordController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    hideText: true,
                    label: 'Confirm Password',
                    hintText: '******',
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    onPressed: _registerUser,
                    text: 'Sign up',
                    backgroundColor: const Color.fromARGB(255, 70, 111, 201),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
