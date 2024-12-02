import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true); // Confirm action
            },
            // style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(confirmText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false); // Cancel action
            },
            child: Text(cancelText),
          ),
        ],
      );
    },
  );
}
