import 'package:enrollease/firebase_options.dart';
import 'package:enrollease/landing_pages/welcome_screen.dart';
import 'package:enrollease/states_management/side_menu_index_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => SideMenuIndexController(),
          ),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WelcomeScreen(),
        ),
      );
}
