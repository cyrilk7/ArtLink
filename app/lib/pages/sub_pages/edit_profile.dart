import 'package:ashlink/controllers/user_controller.dart';
import 'package:ashlink/models/user_model.dart';
import 'package:ashlink/widgets/custom_alert.dart';
import 'package:ashlink/widgets/custom_button.dart';
import 'package:ashlink/widgets/custom_datepicker.dart';
import 'package:ashlink/widgets/custom_dropdown.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:ashlink/widgets/custom_text_field.dart';
import 'package:ashlink/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfile extends StatefulWidget {
  final User user;
  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final userController = UserController();

  @override
  void initState() {
    super.initState();

    _usernameController.text = widget.user.username;
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _phoneNumberController.text = widget.user.phoneNumber;
    _emailController.text = widget.user.email;
    _dobController.text = widget.user.dob;
    _genderController.text = widget.user.gender;
  }

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
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
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

  void _editUser() async {
    try {
      if (validateFields()) {
        await userController.editUser(
            _firstNameController.text,
            _lastNameController.text,
            _emailController.text,
            _phoneNumberController.text);

        Navigator.pop(context, true);
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
        leading: CustomIconButton(
          buttonIcon: Icons.arrow_back,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.museoModerno(
            textStyle: const TextStyle(
              color: Color.fromARGB(255, 70, 111, 201),
              fontWeight: FontWeight.bold,
              // fontSize: 22,
            ),
          ),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 10),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: UserAvatar(userName: widget.user.firstName),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 70, 111, 201),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ), //
                  ),
                  onPressed: () {},
                  child: const Text('Change Image'),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  enabled: false,
                  label: 'Username',
                  hintText: 'janedoe10',
                  controller: _usernameController,
                ),
                const SizedBox(
                  height: 10,
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
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  enabled: false,
                  label: 'Date of Birth',
                  hintText: 'yyyy-mm-dd',
                  controller: _dobController,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  enabled: false,
                  label: 'Gender',
                  hintText: 'Jane',
                  controller: _genderController,
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
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                  onPressed: _editUser,
                  text: 'Save changes',
                  backgroundColor: const Color.fromARGB(255, 70, 111, 201),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
