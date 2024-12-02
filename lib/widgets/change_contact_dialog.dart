import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_validator.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/custom_textformfields.dart';
import 'package:flutter/material.dart';

class ChangeContactNumberDialog extends StatefulWidget {
  final String oldContactNo;
  final String uid;
  const ChangeContactNumberDialog(this.uid, {required this.oldContactNo, super.key});

  @override
  State<ChangeContactNumberDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeContactNumberDialog> {
  final auth = FirebaseAuthProvider();
  late final TextEditingController contactNoController;
  final formKey = GlobalKey<FormState>();
  Widget msg = const SizedBox.shrink();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    contactNoController = TextEditingController(text: widget.oldContactNo);
    contactNoController.addListener(_ensurePrefix);
  }

  void _ensurePrefix() {
    const prefix = '+63';
    if (!contactNoController.text.startsWith(prefix)) {
      contactNoController.text = prefix;
      contactNoController.selection = TextSelection.fromPosition(
        TextPosition(offset: contactNoController.text.length),
      );
    }
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
                'Change contact number',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Enter your new contact number:',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                toShowIcon: false,
                toShow: false,
                toShowPrefixIcon: true,
                controller: contactNoController,
                hintText: 'Contact Number',
                maxLength: 13,
                iconData: const Icon(Icons.numbers),
                isPhoneNumber: true,
                validator: (value) => TextValidator.validateContact(value),
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
                        final contactNo = contactNoController.text.trim();
                        if (contactNo != widget.oldContactNo) {
                          toggleLoading();
                          final result = await auth.changeContactNo(widget.uid, contactNoController.text.trim());
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
