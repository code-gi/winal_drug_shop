import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // Base URL for the email service API
  static const String baseUrl =
      'https://winaldrugshop-backend.onrender.com/api';

  // Send welcome email to newly registered user
  static Future<Map<String, dynamic>> sendWelcomeEmail({
    required String name,
    required String email,
  }) async {
    try {
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
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
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
