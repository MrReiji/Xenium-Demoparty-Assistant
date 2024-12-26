import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Copies the provided text to the clipboard and shows a SnackBar notification.
Future<void> copyToClipboard(BuildContext context, String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Copied to clipboard: $text"),
        duration: const Duration(seconds: 2),
      ),
    );
  } catch (e) {
    debugPrint("Error copying to clipboard: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to copy to clipboard"),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
