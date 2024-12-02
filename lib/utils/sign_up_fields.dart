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
  final TextEditingController userRoleTextController; // For dropdown
  final bool toShowPassword;

  SignUpFieldsConfig({
    required this.userTextController,
    required this.emailTextController,
    required this.contactTextController,
    required this.passwordTextController,
    required this.confirmPasswordTextController,
    required this.userRoleTextController, // Pass in controller for dropdown
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
        'validator': (String? value) =>
            TextValidator.validateEmail(value!.trim()),
      },
      {
        'controller': contactTextController,
        'hintText': 'Contact Number',
        'iconData': const Icon(Icons.numbers),
        'toShow': false,
        'toShowIcon': false,
        'isPhoneNumber': true,
        'maxLength': 13,
        'validator': (String? value) => TextValidator.validateContact(value),
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
          } else if (value.isEmpty) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      },
      // New Dropdown Field for Parent or Guardian
      {
        'controller': userRoleTextController,
        'hintText': 'Role (Parent/Guardian)',
        'iconData': const Icon(Icons.group),
        'toShow': false,
        'toShowIcon': false,
        'isPhoneNumber': false,
        'maxLength': 50,
        'validator': (String? value) {
          if (value == null || value.isEmpty) {
            return 'Please select a role';
          }
          return null;
        },
        'isDropdown': true, // Flag indicating that this field is a dropdown
        'dropdownItems': ['Parent', 'Guardian'], // Dropdown options
      },
    ];
  }
}
