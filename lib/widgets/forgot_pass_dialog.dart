import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_validator.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:flutter/material.dart';

class ForgotPassDialog extends StatefulWidget {
  const ForgotPassDialog({super.key});

  @override
  State<ForgotPassDialog> createState() => _ForgotPassDialogState();
}

class _ForgotPassDialogState extends State<ForgotPassDialog> {
  final authProvider = FirebaseAuthProvider();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Password recovery',
                style: TextStyle(color: Colors.black, fontSize: 23),
              ),
              const Text(
                'Enter the email of your account.',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 400,
                child: CustomTextFormField(
                  toShowIcon: false,
                  toShow: false,
                  iconData: const Icon(Icons.email),
                  toShowPrefixIcon: true,
                  controller: emailController,
                  hintText: 'Email',
                  validator: (e) => TextValidator.simpleValidator(e),
                ),
              ),
              const SizedBox(height: 10),
              CustomBtn(
                vertical: 10,
                colorBg: loading ? Colors.grey : CustomColors.appBarColor,
                colorTxt: Colors.white,
                btnTxt: loading ? 'Processing ...' : 'Submit',
                txtSize: 16,
                onTap: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      loading = !loading;
                    });
                    final result = await authProvider.recoverPass(emailController.text.trim());
                    if (result == null) {
                      if (!context.mounted) return;
                      Nav.pop(context, true);
                    } else {
                      if (!context.mounted) return;
                      Nav.pop(context, false);
                    }
                    setState(() {
                      loading = !loading;
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
