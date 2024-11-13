// lib/config/sign_up_fields.dart

import 'package:enrollease/utils/text_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpFieldsConfig {
  // Initialize controllers for the fields
  final TextEditingController userTextController;
  final TextEditingController emailTextController;
  final TextEditingController contactTextController;
  final TextEditingController passwordTextController;
  final TextEditingController confirmPasswordTextController;
  final bool toShowPassword;

  SignUpFieldsConfig({
    required this.userTextController,
    required this.emailTextController,
    required this.contactTextController,
    required this.passwordTextController,
    required this.confirmPasswordTextController,
    this.toShowPassword = true,
  });

  List<Map<String, dynamic>> getFields() {
    return [
      {
        'controller': userTextController,
        'hintText': 'Full Name (e.g Juan Dela J. Cruz)',
        'iconData': const Icon(CupertinoIcons.person_crop_circle),
        'toShow': false,
        'toShowIcon': false,
        'isPhoneNumber': false,
        'maxLength': 50,
        'validator': (String? value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your full name';
          }
          return null;
        },
      },
      {
        'controller': emailTextController,
        'hintText': 'Email',
        'iconData': const Icon(Icons.email),
        'toShow': false,
        'toShowIcon': false,
        'isPhoneNumber': false,
        'maxLength': 50,
        'validator': (String? value) {
          if (value == null || value.isEmpty || !value.contains('@')) {
            return 'Please enter a valid email';
          } else {
            return TextValidator.validateEmail(value.trim());
          }
        },
      },
      {
        'controller': contactTextController,
        'hintText': 'Contact Number',
        'iconData': const Icon(Icons.numbers),
        'toShow': false,
        'toShowIcon': false,
        'isPhoneNumber': true,
        'maxLength': 13,
        'validator': (String? value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your contact number';
          }
          return null;
        },
      },
      {
        'controller': passwordTextController,
        'hintText': 'Password',
        'iconData': const Icon(Icons.lock),
        'toShow': toShowPassword,
        'toShowIcon': true,
        'isPhoneNumber': false,
        'maxLength': 50,
        'validator': (String? value) {
          if (value == null || value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      },
      {
        'controller': confirmPasswordTextController,
        'hintText': 'Confirm Password',
        'iconData': const Icon(Icons.lock),
        'toShow': toShowPassword,
        'toShowIcon': true,
        'isPhoneNumber': false,
        'maxLength': 50,
        'validator': (String? value) {
          if (value == null || value != passwordTextController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      },
    ];
  }
}
