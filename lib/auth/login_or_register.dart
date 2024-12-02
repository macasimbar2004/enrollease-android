import 'package:enrollease/landing_pages/sign_in.dart';
import 'package:enrollease/landing_pages/sign_up.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Initially show the login page
  bool showLoginPage = true;

  // Toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.signInColor,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Customize animation type here (e.g., Fade, Slide, etc.)
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(
                    showLoginPage ? -0.5 : 0.5, 0.0), // Slide from the right
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: showLoginPage
              ? SignIn(
                  key: const ValueKey('SignIn'),
                  onTap: togglePages,
                )
              : SignUp(
                  key: const ValueKey('SignUp'),
                  onTap: togglePages,
                ),
        ),
      ),
    );
  }
}
