import 'package:flutter/material.dart';

class ConfirmDialog {
  static Future<bool> show(BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xac nhan',
    String cancelLabel = 'Huy',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel, style: destructive ? TextStyle(color: Colors.red) : null),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
