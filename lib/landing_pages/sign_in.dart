import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/landing_pages/sign_up.dart';
import 'package:enrollease/utils/navigation_helper.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:enrollease/widgets/pages_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final userTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  bool toShow = true;

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                          radius: 80,
                          child: Image.asset(CustomLogos.adventistLogo)),
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    RichText(
                      text: TextSpan(
                        style: CustomTextStyles.lusitanaFont(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ), // Default style for the text
                        children: const <TextSpan>[
                          TextSpan(
                              text: 'WELCOME TO SDA PRIVATE\n',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)), // Bold text
                          TextSpan(
                              text: 'SCHOOL ONLINE\n',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: 'ENROLLMENT',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)), // Bold text
                        ],
                      ),
                      textAlign: TextAlign.center, // Center the text
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      toShow: false,
                      toShowIcon: false,
                      toShowPrefixIcon: true,
                      controller: userTextController,
                      hintText: 'Enter Username',
                      iconData: CupertinoIcons.person_crop_circle,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomTextFormField(
                      toShow: toShow,
                      toShowIcon: true,
                      toShowPrefixIcon: true,
                      controller: passwordTextController,
                      hintText: 'Enter Password',
                      iconData: Icons.lock,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.black),
                          )),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomBtn(
                          onTap: () {
                            navigateWithAnimation(
                                context,
                                const PagesController(),
                              );
                          },
                          vertical: 10,
                          colorBg: CustomColors.bottomNavColor,
                          colorTxt: Colors.white,
                          btnTxt: 'Sign In',
                          btnFontWeight: FontWeight.normal,
                          textStyle: CustomTextStyles.lusitanaFont(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                          txtSize: null),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => navigateWithAnimation(
                            context,
                            const SignUp(),
                          ),
                          child: const Text(
                            'SignUp now',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
