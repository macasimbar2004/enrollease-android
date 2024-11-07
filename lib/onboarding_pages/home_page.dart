import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/model/app_size.dart';
import 'package:enrollease/states_management/side_menu_index_controller.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);

    // Access the provider
    final menuProvider = context.read<SideMenuIndexController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.bars,
              size: 34,
            )),
        title: Text(
          'DASHBOARD',
          style: CustomTextStyles.inknutAntiquaBlack(
            fontSize: 15,
            color: Colors.white,
          ), // Example of passing values
        ),
      ),
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, bottom: 10, left: 10),
                  child: Text(
                    'Welcome Parent\'s!',
                    style: CustomTextStyles.inknutAntiquaBlack(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.white), // Example of passing values
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    style: CustomTextStyles.inknutAntiquaBlack(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
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
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                    radius: 80, child: Image.asset(CustomLogos.adventistLogo)),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    'Oroquieta SDA (Seventh-day Adventist) Private School Founded in Oroquieta City, Misamis Occidental, the school has grown over the years, attracting students from various backgrounds. The school fosters an environment of moral integrity and service, providing opportunities for students to participate in outreach programs and community service, a key tenet of Adventist education.',
                    style: CustomTextStyles.macondoFont(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 200,
                  child: CustomBtn(
                      onTap: () => menuProvider.setSelectedIndex(1),
                      vertical: 10,
                      colorBg: CustomColors.bottomNavColor,
                      colorTxt: Colors.white,
                      btnTxt: 'ENROLL NOW',
                      btnFontWeight: FontWeight.normal,
                      textStyle: CustomTextStyles.macondoFont(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                      txtSize: null),
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
