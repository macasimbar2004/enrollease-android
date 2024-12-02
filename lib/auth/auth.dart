import 'package:enrollease/auth/login_or_register.dart';
import 'package:enrollease/widgets/pages_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //  user is logged in
            if (snapshot.hasData) {
              return const PagesController();
            }
            //  user is NOT logged in
            else {
              return const LoginOrRegister();
            }
          }),
    );
  }
}
