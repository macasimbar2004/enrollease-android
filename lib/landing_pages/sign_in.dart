import 'package:enrollease/dev.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:enrollease/widgets/custom_toast.dart';
import 'package:enrollease/widgets/forgot_pass_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function()? onTap;
  const SignIn({super.key, required this.onTap});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final userTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuthProvider _authProvider = FirebaseAuthProvider(); // Initialize FirebaseAuthProvider

  bool toShow = true;

  bool isTapped = false;

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    userTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.signInColor,
      body: SafeArea(
          bottom: false,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(radius: 80, child: Image.asset(CustomLogos.adventistLogo)),
                      ),
                      const SizedBox(height: 5),
                      const Divider(
                        color: Colors.black45,
                        indent: 20,
                        endIndent: 20,
                      ),
                      const SizedBox(height: 15),
                      RichText(
                        text: TextSpan(
                          style: CustomTextStyles.lusitanaFont(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ), // Default style for the text
                          children: const <TextSpan>[
                            TextSpan(
                              text: 'WELCOME TO\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'SDA PRIVATE SCHOOL\n',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            TextSpan(
                              text: ' ONLINE ENROLLMENT',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center, // Center the text
                      ),
                      const SizedBox(height: 30),
                      CustomTextFormField(
                        toShow: false,
                        toShowIcon: false,
                        toShowPrefixIcon: true,
                        controller: userTextController,
                        // toShowLabelText: true,
                        hintText: 'Email',
                        iconData: const Icon(CupertinoIcons.person_crop_circle),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null; // Field is valid
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextFormField(
                        toShow: toShow,
                        toShowIcon: true,
                        toShowPrefixIcon: true,
                        // toShowLabelText: true,
                        controller: passwordTextController,
                        hintText: 'Password',
                        iconData: const Icon(Icons.lock),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null; // Field is valid
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                            onPressed: () async {
                              final result = await showDialog(context: context, builder: (context) => const ForgotPassDialog());
                              if (result is bool && result) {
                                if (!context.mounted) return;
                                DelightfulToast.showSuccess(context, 'Success!', 'A password reset link has been sent to your email.');
                              } else if (result is String) {
                                if (!context.mounted) return;
                                DelightfulToast.showSuccess(context, 'Error', result);
                              }
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blueAccent,
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: 200,
                        child: CustomBtn(
                            onTap: isTapped
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      await handleSignInMethod(context);
                                    } else {
                                      dPrint('Form is invalid, show errors.');
                                    }
                                    // navigateWithAnimation(
                                    //   context,
                                    //   const PagesController(),
                                    // );
                                  },
                            vertical: 10,
                            colorBg: CustomColors.bottomNavColor,
                            colorTxt: Colors.white,
                            btnIcon: isTapped ? Icons.refresh : null,
                            btnTxt: isTapped ? 'Loading' : 'Sign In',
                            btnFontWeight: FontWeight.normal,
                            textStyle: CustomTextStyles.lusitanaFont(fontSize: 16, color: Colors.white, fontWeight: FontWeight.normal),
                            txtSize: null),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextButton(
                            onPressed: widget.onTap,
                            child: const Text(
                              'Sign up now',
                              style: TextStyle(
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Future<void> handleSignInMethod(BuildContext context) async {
    if (!context.mounted) return;

    setState(() {
      isTapped = true;
    });

    final email = userTextController.text.toLowerCase().trim();
    final password = passwordTextController.text.trim();

    // Attempt to log in
    final user = await _authProvider.logIn(context, email: email, password: password);

    if (user != null) {
      // Successful login
      if (context.mounted) {
        setState(() {
          isTapped = false;
        });
      }
    } else {
      if (!context.mounted) return;

      if (context.mounted) {
        setState(() {
          isTapped = false;
        });
      }

      // Login failed
      final errorMessage = _authProvider.authErrorMessage ?? 'Login failed. Please try again.';
      DelightfulToast.showError(context, 'Info', errorMessage);
    }
  }
}
