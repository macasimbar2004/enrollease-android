import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_validator.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:flutter/material.dart';

class ChangeNameDialog extends StatefulWidget {
  final String oldName;
  final String uid;
  const ChangeNameDialog(this.uid, {required this.oldName, super.key});

  @override
  State<ChangeNameDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeNameDialog> {
  final auth = FirebaseAuthProvider();
  late final TextEditingController nameController;
  final formKey = GlobalKey<FormState>();
  Widget msg = const SizedBox.shrink();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.oldName);
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
                'Change name',
                style: TextStyle(color: Colors.black, fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Enter your new name:',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                toShowIcon: false,
                toShow: false,
                toShowPrefixIcon: true,
                controller: nameController,
                hintText: 'Name',
                iconData: const Icon(Icons.person),
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
                        final name = nameController.text.trim();
                        if (name != widget.oldName) {
                          toggleLoading();
                          final result = await auth.changeUserName(widget.uid, nameController.text.trim());
                          if (result is String) {
                            updateMsg(result);
                          } else {
                            if (!context.mounted) return;
                            Nav.pop(context);
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
