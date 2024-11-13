import 'dart:math';

import 'package:enrollease/landing_pages/otp_verification.dart';
import 'package:enrollease/model/user_model.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/custom_loading_dialog.dart';
import 'package:enrollease/utils/email_provider.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/sign_up_fields.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/landing_pages/sign_in.dart';
import 'package:enrollease/model/app_size.dart';
import 'package:enrollease/utils/navigation_helper.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:enrollease/widgets/custom_toast.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final userTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final contactTextController = TextEditingController(text: '+63');
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool toShowPassword = true;

  @override
  void initState() {
    super.initState();
    contactTextController.addListener(_ensurePrefix);
  }

  void _ensurePrefix() {
    const prefix = '+63';
    if (!contactTextController.text.startsWith(prefix)) {
      contactTextController.text = prefix;
      contactTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: contactTextController.text.length),
      );
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    contactTextController.removeListener(_ensurePrefix);
    userTextController.dispose();
    emailTextController.dispose();
    contactTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  // Method to generate a 6-digit OTP
  String generateOtp() {
    final random = Random();
    final otp = random.nextInt(900000) + 100000; // Ensures a 6-digit OTP
    return otp.toString();
  }

  // Method to send OTP email
  Future<void> sendOtpEmail(
      String email, String otpCode, String userName) async {
    await sendEmail(email: email, otpCode: otpCode, userName: userName);
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);

    // Create an instance of SignUpFieldsConfig
    final fieldsConfig = SignUpFieldsConfig(
      userTextController: userTextController,
      emailTextController: emailTextController,
      contactTextController: contactTextController,
      passwordTextController: passwordTextController,
      confirmPasswordTextController: confirmPasswordTextController,
      toShowPassword: toShowPassword, // Pass visibility state
    );

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
                    ...fieldsConfig.getFields().map((field) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: CustomTextFormField(
                            toShowPrefixIcon: true,
                            toShow: field['toShow'],
                            toShowIcon: field['toShowIcon'],
                            controller: field['controller'],
                            hintText: field['hintText'],
                            iconData: field['iconData'],
                            isPhoneNumber: field['isPhoneNumber'],
                            maxLength: field['maxLength'],
                            validator:
                                field['validator'] as String? Function(String?),
                          ),
                        )),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: CustomBtn(
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            await handleSaveMethod(context);
                          } else {
                            debugPrint("Form is invalid, show errors.");
                          }
                        },
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleSaveMethod(BuildContext context) async {
    final otpCode = generateOtp(); // Generate OTP
    showLoadingDialog(context, 'Loading...'); // Show loading dialog

    try {
      // Send OTP email
      await sendOtpEmail(emailTextController.text.trim(), otpCode,
          userTextController.text.trim());

      // If the form is valid, process the signup
      if (context.mounted) {
        Navigator.of(context).pop();

        final user = UserModel(
          name: userTextController.text.trim(),
          email: emailTextController.text.trim().toLowerCase(),
          contactNumber: contactTextController.text.trim(),
        );

        DelightfulToast.showSuccess(context, 'Success', "OTP has been sent.");

        navigateWithAnimation(
          context,
          OtpVerificationScreen(
            user: user,
            otpCode: otpCode,
            password: passwordTextController.text.trim(),
          ),
        );
      }
    } catch (ex) {
      debugPrint(ex.toString());
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    debugPrint("Form is valid, proceed with signup.");
  }
}

// await FirebaseAuth.instance.verifyPhoneNumber(
//     verificationCompleted:
//         (PhoneAuthCredential credential) {},
//     verificationFailed:
//         (FirebaseAuthException ex) {},
//     codeSent: (String verificationId,
//         int? resendToken) {
//       navigateWithAnimation(
//         context,
//         OtpVerificationScreen(
//           verificationId: verificationId,
//         ),
//       );
//     },
//     codeAutoRetrievalTimeout:
//         (String verificationId) {},
//     phoneNumber: contactTextController.text
//         .trim()
//         .toString());
