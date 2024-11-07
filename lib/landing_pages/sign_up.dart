import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/landing_pages/sign_in.dart';
import 'package:enrollease/model/app_size.dart';
import 'package:enrollease/utils/navigation_helper.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    final userTextController = TextEditingController();
    final emailTextController = TextEditingController();
    final contactTextController = TextEditingController();
    final passwordTextController = TextEditingController();
    final confirmPasswordTextController = TextEditingController();

    bool toShowPassword = true;

    // List of maps defining each text field's properties
    final List<Map<String, dynamic>> fields = [
      {
        'controller': userTextController,
        'hintText': 'Full Name (e.g Juan Dela J. Cruz)',
        'iconData': CupertinoIcons.person_crop_circle,
        'toShow': false,
        'toShowIcon': false,
      },
      {
        'controller': emailTextController,
        'hintText': 'Email',
        'iconData': Icons.email,
        'toShow': false,
        'toShowIcon': false,
      },
      {
        'controller': contactTextController,
        'hintText': 'Contact Number',
        'iconData': Icons.numbers,
        'toShow': false,
        'toShowIcon': false,
      },
      {
        'controller': passwordTextController,
        'hintText': 'Password',
        'iconData': Icons.lock,
        'toShow': toShowPassword,
        'toShowIcon': true,
      },
      {
        'controller': confirmPasswordTextController,
        'hintText': 'Confirm Password',
        'iconData': Icons.lock,
        'toShow': toShowPassword,
        'toShowIcon': true,
      },
    ];

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
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 80,
                      child: Image.asset(CustomLogos.adventistLogo),
                    ),
                  ),
                  const Divider(color: Colors.black),
                  RichText(
                    text: TextSpan(
                      style: CustomTextStyles.lusitanaFont(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      children: const <TextSpan>[
                        TextSpan(
                          text: 'WELCOME TO SDA PRIVATE\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'SCHOOL ONLINE\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'ENROLLMENT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Generate CustomTextFormFields dynamically
                  ...fields.map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: CustomTextFormField(
                          toShowPrefixIcon: true,
                          toShow: field['toShow'],
                          toShowIcon: field['toShowIcon'],
                          controller: field['controller'],
                          hintText: field['hintText'],
                          iconData: field['iconData'],
                        ),
                      )),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: CustomBtn(
                      onTap: () {},
                      vertical: 10,
                      colorBg: CustomColors.bottomNavColor,
                      colorTxt: Colors.white,
                      btnTxt: 'Sign Up',
                      btnFontWeight: FontWeight.normal,
                      textStyle: CustomTextStyles.lusitanaFont(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                      txtSize: null,
                    ),
                  ),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => navigateWithAnimation(
                          context,
                          const SignIn(),
                        ),
                        child: const Text(
                          'SignIn now',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.black)),
                      Text(' Or '),
                      Expanded(child: Divider(color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomBtn(
                        vertical: 0,
                        height: 40,
                        colorBg: Colors.white,
                        colorTxt: Colors.black,
                        btnTxt: 'Signup with Google',
                        btnFontWeight: FontWeight.normal,
                        txtSize: 16,
                        imageAsset: CustomLogos.googlePNGLogo,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      CustomBtn(
                        vertical: 0,
                        height: 40,
                        colorBg: Colors.white,
                        colorTxt: Colors.black,
                        btnTxt: 'Signup with Facebook',
                        btnFontWeight: FontWeight.normal,
                        txtSize: 16,
                        imageAsset: CustomLogos.facebookPNGLogo,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
