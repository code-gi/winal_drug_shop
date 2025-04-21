// filepath: d:\projects\winal_drug_shop\lib\utils\email_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'dart:math';
import 'dart:developer' as developer;

class EmailService {
  // Base URL for the email service API
  static const String baseUrl =
      'https://winaldrugshop-backend.onrender.com/api';

  // SendGrid API key - This should be stored securely in a configuration file or env variable
  // For this example, we'll include it directly, but in production, get this from secure storage
  static const String sendGridApiKey = 'YOUR_SENDGRID_API_KEY';
  static const String fromEmail = 'noreply@winaldrugshop.com';
  static const String fromName = 'Winal Drug Shop';

  static final Map<String, String> _verificationCodes = {};

  // Generate a random verification code
  static String _generateVerificationCode() {
    final Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Store verification code in memory (in production, store in a database with expiration)
  static void _storeVerificationCode(String email, String code) {
    _verificationCodes[email] = code;
  }

  // Verify the code
  static bool verifyCode(String email, String code) {
    final storedCode = _verificationCodes[email];
    if (storedCode == null) return false;
    return storedCode == code;
  }

  // Clear the verification code after use
  static void clearVerificationCode(String email) {
    _verificationCodes.remove(email);
  }

  // Send password reset email using SendGrid
  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      // Generate verification code
      final verificationCode = _generateVerificationCode();
      _storeVerificationCode(email, verificationCode);

      // Try SendGrid first
      try {
        final mailer = Mailer(sendGridApiKey);
        final toAddress = Address(email);

        final personalization = Personalization(
          [toAddress],
          dynamicTemplateData: {
            'verification_code': verificationCode,
          },
        );

        final fromAddress = Address(fromEmail, fromName);

        // Create HTML content for the email
        final htmlContent = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
            <div style="text-align: center; margin-bottom: 20px;">
              <h2 style="color: #2196F3;">Winal Drug Shop</h2>
            </div>
            <div>
              <h3>Password Reset</h3>
              <p>You requested a password reset for your Winal Drug Shop account.</p>
              <p>Your verification code is:</p>
              <div style="background-color: #f5f5f5; padding: 15px; text-align: center; font-size: 24px; letter-spacing: 5px; border-radius: 5px; margin: 20px 0;">
                <strong>$verificationCode</strong>
              </div>
              <p>This code will expire in 15 minutes.</p>
              <p>If you did not request a password reset, please ignore this email or contact our support team if you have concerns.</p>
              <hr style="margin: 20px 0; border: none; border-top: 1px solid #e0e0e0;">
              <p style="font-size: 12px; color: #757575; text-align: center;">
                &copy; ${DateTime.now().year} Winal Drug Shop. All rights reserved.
              </p>
            </div>
          </div>
        ''';

        // Create plain text content as backup
        final textContent =
            'Your password reset code is: $verificationCode. This code will expire in 15 minutes.';

        // Create email with proper content structure
        final resetEmail = Email(
            [personalization], fromAddress, 'Password Reset - Winal Drug Shop',
            content: [
              Content('text/plain', textContent),
              Content('text/html', htmlContent)
            ]);

        // Send the email
        await mailer.send(resetEmail);

        developer.log('Password reset email sent via SendGrid to: $email');

        return {
          'success': true,
          'message': 'Password reset email sent successfully',
        };
      } catch (e) {
        developer.log('SendGrid error, falling back to API: ${e.toString()}');
        // If SendGrid fails, fallback to the backend API
        return await _sendPasswordResetEmailViaApi(email, verificationCode);
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending password reset email: ${e.toString()}',
      };
    }
  }

  // Fallback to using the backend API for sending password reset
  static Future<Map<String, dynamic>> _sendPasswordResetEmailViaApi(
      String email, String verificationCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/password-reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'verification_code': verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset email sent successfully',
        };
      } else {
        // Try to parse error message from response
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          // If parsing fails, use a generic message
        }

        return {
          'success': false,
          'message':
              errorData['message'] ?? 'Failed to send password reset email',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      // For local development or testing
      return _sendLocalPasswordResetEmail(email, verificationCode);
    }
  }

  // For local testing or if backend and SendGrid are not available
  static Future<Map<String, dynamic>> _sendLocalPasswordResetEmail(
      String email, String verificationCode) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    print('📧 PASSWORD RESET EMAIL');
    print('To: $email');
    print('Subject: Password Reset - Winal Drug Shop');
    print('--------------------');
    print('Your verification code is: $verificationCode');
    print('This code will expire in 15 minutes.');
    print('--------------------');

    return {
      'success': true,
      'message': 'Password reset email sent successfully (local simulation)',
    };
  }

  // Send welcome email to newly registered user
  static Future<Map<String, dynamic>> sendWelcomeEmail({
    required String name,
    required String email,
  }) async {
    try {
      // Try SendGrid first
      try {
        final mailer = Mailer(sendGridApiKey);
        final toAddress = Address(email);

        final personalization = Personalization(
          [toAddress],
          dynamicTemplateData: {
            'name': name,
          },
        );

        final fromAddress = Address(fromEmail, fromName);

        // Create HTML content for welcome email
        final htmlContent = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
            <div style="text-align: center; margin-bottom: 20px;">
              <h2 style="color: #2196F3;">Winal Drug Shop</h2>
            </div>
            <div>
              <h3>Welcome to Winal Drug Shop!</h3>
              <p>Dear $name,</p>
              <p>Thank you for registering with Winal Drug Shop! Your account has been successfully created.</p>
              <p>With your new account, you can:</p>
              <ul>
                <li>Browse our wide range of animal and human medications</li>
                <li>Book appointments for farm activities and consultations</li>
                <li>Track your orders and prescription history</li>
                <li>Access exclusive health tips and resources</li>
              </ul>
              <p>If you have any questions or need assistance, please don't hesitate to contact us.</p>
              <p>Best regards,<br>The Winal Drug Shop Team</p>
              <hr style="margin: 20px 0; border: none; border-top: 1px solid #e0e0e0;">
              <p style="font-size: 12px; color: #757575; text-align: center;">
                &copy; ${DateTime.now().year} Winal Drug Shop. All rights reserved.
              </p>
            </div>
          </div>
        ''';

        // Create plain text content as backup
        final textContent =
            'Dear $name, Thank you for registering with Winal Drug Shop! Your account has been successfully created.';

        // Create email with proper content structure
        final welcomeEmail = Email(
            [personalization], fromAddress, 'Welcome to Winal Drug Shop!',
            content: [
              Content('text/plain', textContent),
              Content('text/html', htmlContent)
            ]);

        // Send the email
        await mailer.send(welcomeEmail);

        developer.log('Welcome email sent via SendGrid to: $email');

        return {
          'success': true,
          'message': 'Welcome email sent successfully',
        };
      } catch (e) {
        developer.log('SendGrid error, falling back to API: ${e.toString()}');
        // If SendGrid fails, fallback to the backend API
        final response = await http.post(
          Uri.parse('$baseUrl/notifications/welcome-email'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'name': name,
            'email': email,
          }),
        );

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': 'Welcome email sent successfully',
          };
        } else {
          // Try to parse error message from response
          Map<String, dynamic> errorData = {};
          try {
            errorData = json.decode(response.body);
          } catch (e) {
            // If parsing fails, use a generic message
          }

          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to send welcome email',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      return sendLocalWelcomeEmail(name: name, email: email);
    }
  }

  // For local testing or if backend is not available yet
  static Future<Map<String, dynamic>> sendLocalWelcomeEmail({
    required String name,
    required String email,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    print('📧 WELCOME EMAIL');
    print('To: $email');
    print('Subject: Welcome to Winal Drug Shop!');
    print('--------------------');
    print('Dear $name,');
    print('');
    print('Thank you for registering with Winal Drug Shop!');
    print('Your account has been successfully created.');
    print('');
    print('With your new account, you can:');
    print('• Browse our wide range of animal and human medications');
    print('• Book appointments for farm activities and consultations');
    print('• Track your orders and prescription history');
    print('• Access exclusive health tips and resources');
    print('');
    print(
        'If you have any questions or need assistance, please don\'t hesitate to contact us.');
    print('');
    print('Best regards,');
    print('The Winal Drug Shop Team');
    print('--------------------');

    return {
      'success': true,
      'message': 'Welcome email sent successfully (local simulation)',
    };
  }
}
