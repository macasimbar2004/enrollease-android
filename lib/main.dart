import 'package:appwrite/appwrite.dart';
import 'package:enrollease/auth/auth.dart';
import 'package:enrollease/firebase_options.dart';
import 'package:enrollease/landing_pages/welcome_screen.dart';
import 'package:enrollease/states_management/account_data_controller.dart';
import 'package:enrollease/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease/states_management/side_menu_index_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;
  Client client = Client();
  client.setEndpoint('https://cloud.appwrite.io/v1').setProject('674982d000220a32a166');
  runApp(EnrollEase(showHome: showHome));
}

class EnrollEase extends StatelessWidget {
  final bool showHome;
  const EnrollEase({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          // Add the AccountDataController provider here
          ChangeNotifierProvider(
            create: (context) => AccountDataController(),
          ),
          ChangeNotifierProvider(
            create: (context) => SideMenuIndexController(),
          ),
          ChangeNotifierProvider(
            create: (context) => SideMenuDrawerController(),
          ),
        ],
        child: MaterialApp(
          title: 'EnrollEase',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
          ),
          home: showHome ? const AuthPage() : const WelcomeScreen(),
        ),
      );
}
