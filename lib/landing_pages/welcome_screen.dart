import 'package:enrollease/auth/auth.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.signInColor,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(CustomLogos.adventistLogo),
                ),
                const SizedBox(height: 20),
                Text(
                  'ENROLLEASE',
                  style: CustomTextStyles.lusitanaFont(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Navigate Enrollment Easily',
                  style: CustomTextStyles.maShanZhengFont(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 100,
                    child: CustomBtn(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('showHome', true);
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      vertical: 10,
                      colorBg: CustomColors.bottomNavColor,
                      colorTxt: Colors.white,
                      btnTxt: 'Get Started',
                      btnFontWeight: FontWeight.normal,
                      textStyle: CustomTextStyles.lusitanaFont(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                      txtSize: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
