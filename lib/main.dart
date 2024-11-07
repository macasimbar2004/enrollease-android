import 'package:enrollease/landing_pages/welcome_screen.dart';
import 'package:enrollease/states_management/side_menu_index_controller.dart';
import 'package:enrollease/widgets/pages_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

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
