import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/widgets/custom_confirmation_dialog.dart';
import 'package:flutter/material.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  FirebaseAuthProvider auth = FirebaseAuthProvider();

  @override
  Widget build(BuildContext context) {

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: CustomColors.contentColor),
            child: Center(
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Image.asset(
                          CustomLogos.enrolleaseLogo,
                          height: 100.0,
                          width: 80.0,
                        ),
                      ),
                      // Conditionally show the Text widget based on isVisible
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit
                              .scaleDown, // Scales text when space is limited
                          child: Text(
                            'Enrollease',
                            style: CustomTextStyles.lusitanaFont(
                              fontSize: 24,
                              color: CustomColors.appBarColor,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow
                                .ellipsis, // Clip text when it overflows
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              final confirm = await showConfirmationDialog(
                context: context,
                title: 'Confirm Logout',
                message: 'Are you sure you want to logout?',
                confirmText: 'Proceed',
                cancelText: 'Cancel',
              );
              if (confirm == true) {
                if (context.mounted) {
                  await auth.logOut(context);
                }
              } else {
                debugPrint('Logout canceled by user.');
              }
            },
            child: const ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log out'),
            ),
          )
        ],
      ),
    );
  }
}
