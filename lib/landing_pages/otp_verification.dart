import 'package:enrollease/model/user_model.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/custom_loading_dialog.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:enrollease/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:enrollease/auth/auth.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen(
      {super.key,
      required this.user,
      required this.otpCode,
      required this.password});

  final UserModel user;
  final String otpCode;
  final String password;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpCodeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuthProvider _authProvider = FirebaseAuthProvider();

  Future<void> _signUp(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      // Show loading indicator
      showLoadingDialog(context, 'Verifying...');

      // Attempt to sign up user
      final user = await _authProvider.signUp(
        email: widget.user.email,
        password: widget.password,
      );

      if (user != null) {
        try {
          // Save user data in Firestore
          await _authProvider.saveUserData(
              userId: widget.user.uid,
              role: widget.user.role,
              userName: widget.user.userName,
              email: widget.user.email,
              contactNumber: widget.user.contactNumber,
              isActive: widget.user.isActive);

          if (context.mounted) {
            Navigator.of(context).pop(); // Close loading indicator
            DelightfulToast.showSuccess(
                context, 'Success', 'Sign up successful! Please login.');

            await _authProvider.logOut(context);
            await Future.delayed(const Duration(seconds: 1));
          }
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthPage()),
              (route) => false,
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop(); // Close loading indicator
            DelightfulToast.showError(
                context, 'Error', 'Error saving user data: $e');
          }
        }
      } else {
        // Retrieve error message from authErrorMessage if user is null
        final errorMessage =
            _authProvider.authErrorMessage ?? 'Sign up failed.';

        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading indicator
          DelightfulToast.showError(context, 'Error', errorMessage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: CustomColors.signInColor,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: formKey,
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
                    Text(
                      'Enter OTP Code',
                      style: CustomTextStyles.inknutAntiquaBlack(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black), // Example of passing values
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          CustomLogos.philippinesLogo,
                          width: 50,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: CustomTextFormField(
                            toShowIcon: false,
                            toShowLabelText: false,
                            toShow: false,
                            controller: otpCodeController,
                            hintText: 'e.g 123456',
                            isPhoneNumber: true,
                            maxLength: 6,
                            toShowPrefixIcon: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'OTP code invalid';
                              }
                              if (value != widget.otpCode) {
                                return 'OTP code not match';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 100,
                      child: CustomBtn(
                          vertical: 5,
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              // If the otp is valid, next page

                              try {
                                if (widget.otpCode ==
                                    otpCodeController.text.trim()) {
                                  _signUp(context);
                                }
                                //vali
                              } catch (ex) {
                                debugPrint(ex.toString());
                              }

                              debugPrint(
                                  'Form is valid, proceed to next page.');
                            } else {
                              debugPrint('Form is invalid, show errors.');
                            }
                          },
                          colorBg: CustomColors.appBarColor,
                          colorTxt: Colors.black,
                          btnTxt: 'Verify',
                          textStyle: CustomTextStyles.lusitanaFont(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          txtSize: 24),
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
}

//  PhoneAuthCredential credential =
//                                     PhoneAuthProvider.credential(
//                                         verificationId: widget.verificationId,
//                                         smsCode:
//                                             otpCodeController.text.toString());

//                                 FirebaseAuth.instance
//                                     .signInWithCredential(credential)
//                                     .then((value) {
//                                   if (context.mounted) {
//                                     navigateWithAnimation(
//                                       context,
//                                       const PagesController(),
//                                     );
//                                   }
//                                 });