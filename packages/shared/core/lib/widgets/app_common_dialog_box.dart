import 'package:flutter/material.dart';

// region AppCommonDialogBox
class AppCommonDialogBox {
  // region Constructor
  AppCommonDialogBox._(); // Private constructor
  // endregion

  // region Info Dialog
  /// Shows a simple info dialog.
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // endregion

  // region Confirm Dialog
  /// Shows a confirmation dialog.
  /// Returns `true` if confirmed, `false` if cancelled or dismissed.
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    // Return false if dialog is dismissed (null)
    return result ?? false;
  }

  // endregion
}

// endregion










