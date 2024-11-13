import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';

class DelightfulToast {
  static void removeToast() {
    DelightToastBar.removeAll();
  }

  // Success notification
  static void showSuccess(BuildContext context, String? title, String subTitle,
      {dynamic Function()? onTap}) {
    removeToast();

    DelightToastBar(
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ToastCard(
              leading: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              title: Text(
                title ?? 'Success',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.green,
                ),
                softWrap: true, // Allow title to wrap within width
                maxLines: 2, // Limit to 2 lines for compactness
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                subTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.green,
                ),
                softWrap: true, // Allow subtitle to wrap within width
              ),
              onTap: onTap ?? removeToast,
              trailing: const IconButton(
                onPressed: DelightToastBar.removeAll,
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
      autoDismiss: true,
      snackbarDuration: const Duration(milliseconds: 3000),
      position: DelightSnackbarPosition.top,
    ).show(context);
  }

  // Info notification
  static void showInfo(BuildContext context, String? title, String subTitle,
      {dynamic Function()? onTap}) {
    removeToast();

    DelightToastBar(
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ToastCard(
              leading: const Icon(
                Icons.info,
                color: Colors.blue,
              ),
              title: Text(
                title ?? 'Info',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.blue,
                ),
                softWrap: true, // Allows title text to wrap if needed
                maxLines: 2, // Limit lines to 2 for title
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                subTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.blue,
                ),
                softWrap: true, // Allows subtitle text to wrap if needed
              ),
              onTap: onTap ?? removeToast,
              trailing: const IconButton(
                onPressed: DelightToastBar.removeAll,
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
      autoDismiss: true,
      snackbarDuration: const Duration(milliseconds: 3000),
      position: DelightSnackbarPosition.top,
    ).show(context);
  }

  // Error notification
  static void showError(BuildContext context, String? title, String subTitle,
      {dynamic Function()? onTap}) {
    removeToast();

    DelightToastBar(
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ToastCard(
              leading: const Icon(
                Icons.error,
                color: Colors.red,
              ),
              title: Text(
                title ?? 'Error',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.red,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                subTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.red,
                ),
                softWrap: true, // Allows text to wrap to the next line
              ),
              onTap: onTap ?? removeToast,
              trailing: const IconButton(
                onPressed: DelightToastBar.removeAll,
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
      autoDismiss: true,
      snackbarDuration: const Duration(milliseconds: 3000),
      position: DelightSnackbarPosition.top,
    ).show(context);
  }
}
