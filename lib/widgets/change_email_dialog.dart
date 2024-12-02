import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_validator.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:flutter/material.dart';

class ChangeEmailDialog extends StatefulWidget {
  final String oldEmail;
  final String uid;
  const ChangeEmailDialog(this.uid, {required this.oldEmail, super.key});

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final auth = FirebaseAuthProvider();
  late final TextEditingController emailController;
  final formKey = GlobalKey<FormState>();
  Widget msg = const SizedBox.shrink();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.oldEmail);
  }

  void toggleLoading() => setState(() {
        loading = !loading;
      });

  void updateMsg(String text) => setState(() {
        msg = Text(text, style: const TextStyle(color: Colors.red));
      });

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
                'Change email',
                style: TextStyle(color: Colors.black, fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Enter your new email:',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                toShowIcon: false,
                toShow: false,
                toShowPrefixIcon: true,
                controller: emailController,
                hintText: 'Email',
                iconData: const Icon(Icons.mail),
                validator: (value) => TextValidator.validateEmail(value),
              ),
              const SizedBox(height: 10),
              msg,
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomBtn(
                    onTap: () {
                      Nav.pop(context);
                    },
                    vertical: 10,
                    horizontal: 20,
                    colorBg: loading ? Colors.grey : Colors.redAccent,
                    colorTxt: Colors.white,
                    btnTxt: 'Cancel',
                    txtSize: 16,
                  ),
                  const SizedBox(width: 10),
                  CustomBtn(
                    horizontal: 20,
                    onTap: () async {
                      if (loading) return;
                      updateMsg('');
                      if (formKey.currentState!.validate()) {
                        final email = emailController.text.trim();
                        if (email != widget.oldEmail) {
                          toggleLoading();
                          final result = await auth.changeEmail(widget.uid, emailController.text.trim());
                          if (result is String) {
                            updateMsg(result);
                          } else {
                            if (!context.mounted) return;
                            Nav.pop(context, true);
                          }
                          toggleLoading();
                        }
                      }
                    },
                    vertical: 10,
                    colorBg: loading ? Colors.grey : CustomColors.contentColor,
                    colorTxt: Colors.white,
                    btnTxt: 'Change',
                    txtSize: 16,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
