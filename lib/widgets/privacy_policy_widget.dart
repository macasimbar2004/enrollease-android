import 'package:enrollease/privacy_policy.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyWidget extends StatelessWidget {
  const PrivacyPolicyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Markdown(
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(
                    Theme.of(context).copyWith(
                      textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.black),
                    ),
                  ),
                  data: privacyPolicy),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomBtn(
                vertical: 10,
                horizontal: 50,
                colorBg: Colors.blue,
                colorTxt: Colors.white,
                txtSize: 16,
                btnTxt: 'Ok',
                onTap: () {
                  Nav.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
