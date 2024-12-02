import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_validator.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:flutter/material.dart';

class ChangePassDialog extends StatefulWidget {
  final String uid;
  const ChangePassDialog(this.uid, {super.key});

  @override
  State<ChangePassDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangePassDialog> {
  final auth = FirebaseAuthProvider();
  late final TextEditingController passController;
  final formKey = GlobalKey<FormState>();
  Widget msg = const SizedBox.shrink();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    passController = TextEditingController();
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
                'Change password',
                style: TextStyle(color: Colors.black, fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Enter your new password:',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                toShowIcon: true,
                toShow: true,
                toShowPrefixIcon: true,
                controller: passController,
                hintText: 'Password',
                iconData: const Icon(Icons.lock),
                validator: (value) => TextValidator.simpleValidator(value),
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
                        final pass = passController.text.trim();
                        toggleLoading();
                        final result = await auth.changeEmail(widget.uid, pass);
                        if (result is String) {
                          updateMsg(result);
                        } else {
                          if (!context.mounted) return;
                          Nav.pop(context);
                        }
                        toggleLoading();
                        if (!context.mounted) return;
                        Nav.pop(context);
                      }
                    },
                    vertical: 10,
                    colorBg: loading ? Colors.grey : CustomColors.contentColor,
                    colorTxt: Colors.white,
                    btnTxt: 'Change',
                    txtSize: 16,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
