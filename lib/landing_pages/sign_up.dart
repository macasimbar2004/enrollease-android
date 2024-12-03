import 'dart:math';

import 'package:enrollease/dev.dart';
import 'package:enrollease/landing_pages/otp_verification.dart';
import 'package:enrollease/model/user_model.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/custom_loading_dialog.dart';
import 'package:enrollease/utils/email_provider.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/sign_up_fields.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/model/app_size.dart';
import 'package:enrollease/utils/navigation_helper.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:enrollease/widgets/custom_toast.dart';
import 'package:enrollease/widgets/terms_and_conditions_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function()? onTap;
  const SignUp({super.key, required this.onTap});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final userTextController = TextEditingController();
  final userRoleTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final contactTextController = TextEditingController(text: '+63');
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  final scrollController = ScrollController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool toShowPassword = true;
  final FirebaseAuthProvider _authProvider = FirebaseAuthProvider();

  late String idNumber;

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
    userRoleTextController.dispose();
    super.dispose();
  }

  // Method to send OTP email
  Future<void> sendOtpEmail({
    required String email,
    required String userName,
    required String otp,
  }) async {
    await EmailProvider().sendOTP(
      email: email,
      userName: userName,
      otp: otp,
    );
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
      userRoleTextController: userRoleTextController, // Pass in the controller
      toShowPassword: toShowPassword, // Pass visibility state
    );

    return Scaffold(
      backgroundColor: CustomColors.signInColor,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
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
                          radius: 60,
                          child: Image.asset(CustomLogos.adventistLogo),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Divider(
                        color: Colors.black45,
                        indent: 20,
                        endIndent: 20,
                      ),
                      RichText(
                        text: TextSpan(
                          style: CustomTextStyles.lusitanaFont(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Generate CustomTextFormFields dynamically
                      ...fieldsConfig.getFields().map((field) {
                        if (field['isDropdown'] == true) {
                          // Render dropdown for 'Parent' or 'Guardian'
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DropdownButtonFormField<String>(
                              value: userRoleTextController.text.isNotEmpty ? userRoleTextController.text : null,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                hintText: field['hintText'],
                                alignLabelWithHint: true,
                                prefixIcon: field['iconData'],
                                // border: const OutlineInputBorder(),
                              ),
                              items: (field['dropdownItems'] as List<String>).map<DropdownMenuItem<String>>((String role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  userRoleTextController.text = value ?? '';
                                });
                              },
                              validator: field['validator'] as String? Function(String?),
                            ),
                          );
                        } else {
                          // Render normal text form fields
                          return Padding(
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
                              validator: field['validator'] as String? Function(String?),
                            ),
                          );
                        }
                      }),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: 200,
                        child: CustomBtn(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              await handleSaveMethod(context);
                            } else {
                              dPrint('Form is invalid, show errors.');
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
                      // Wrap(
                      //   alignment: WrapAlignment.center,
                      //   crossAxisAlignment: WrapCrossAlignment.center,
                      //   children: [
                      //     RichText(
                      //         text: TextSpan(
                      //       children: [
                      //         TextSpan(text: 'I agree to the '),
                      //         TextSpan(
                      //           text: 'Terms and Conditions',
                      //           recognizer: TapGestureRecognizer()
                      //             ..onTap = () {
                      //               showDialog(context: context, builder: (context) => TermsAndConditionsWidget());
                      //             },
                      //         )
                      //       ],
                      //     )),
                      //   ],
                      // ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextButton(
                            onPressed: widget.onTap,
                            child: const Text(
                              'Sign in instead',
                              style: TextStyle(
                                color: Colors.blueAccent,
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
      ),
    );
  }

  // Method to generate a 6-digit OTP
  String generateOtp() {
    final random = Random();
    final otp = random.nextInt(900000) + 100000; // Ensures a 6-digit OTP
    return otp.toString();
  }

  Future<void> handleSaveMethod(BuildContext context) async {
    final otp = generateOtp();
    showLoadingDialog(context, 'Loading...'); // Show loading dialog

    try {
      idNumber = await _authProvider.generateNewIdentification();

      // Send OTP email
      await sendOtpEmail(
        email: emailTextController.text.trim(),
        userName: userTextController.text.trim(),
        otp: otp,
      );

      // If the form is valid, process the signup
      if (context.mounted) {
        Navigator.of(context).pop();

        final user = UserModel(
          userName: userTextController.text.trim(),
          role: userRoleTextController.text.trim(),
          email: emailTextController.text.trim().toLowerCase(),
          contactNumber: contactTextController.text.trim(),
          uid: idNumber,
          profilePicLink: 'default',
          isActive: true,
        );
        //generate unique id
        DelightfulToast.showSuccess(context, 'Success', 'OTP has been sent.');
        navigateWithAnimation(
          context,
          OtpVerificationScreen(
            user: user,
            otpCode: otp,
            password: passwordTextController.text.trim(),
          ),
        );
      }
    } catch (ex) {
      dPrint(ex.toString());
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    dPrint('Form is valid, proceed with signup.');
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
