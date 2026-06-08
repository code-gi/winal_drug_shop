import 'package:flutter/material.dart';

class DebugHelper {
  static bool isDevelopmentMode = true; // Set to false in production
  
  // Show a debug toast message
  static void showDebugToast(BuildContext context, String message) {
    if (!isDevelopmentMode) return;
    
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'DISMISS',
          onPressed: scaffold.hideCurrentSnackBar,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  // Log to console in dev mode
  static void log(String message) {
    if (isDevelopmentMode) {
      print('🛠️ DEBUG: $message');
    }
  }
  
  // Show a verification code dialog for testing
  static void showVerificationCode(BuildContext context, String email, String code) {
    if (!isDevelopmentMode) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Debug: Verification Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: $email'),
              const SizedBox(height: 10),
              Text(
                'Code: $code',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'This dialog only appears in development mode.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Prints debug information with a specific tag
  static void debugPrint(String tag, String message) {
    print('[$tag] $message');
  }
} 