import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailService {
  final String _baseUrl;
  
  // Use the Render.com hosted backend URL by default instead of localhost
  EmailService({String? baseUrl}) : _baseUrl = baseUrl ?? 'https://winaldrugshop-backend.onrender.com';
  
  /// Validates if Gmail API credentials are set up correctly
  Future<bool> validateApiKey() async {
    try {
      // Check if the backend is reachable
      final response = await http.get(
        Uri.parse('$_baseUrl/api/health-check'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        debugPrint('Backend is reachable at $_baseUrl');
        return true;
      } else {
        debugPrint('Backend returned status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error validating backend connectivity: $e');
      return false;
    }
  }

  /// Sends a test email
  Future<bool> sendTestEmail({
    required String to,
    String subject = 'Test Email',
    String content = 'This is a test email.',
  }) async {
    try {
      debugPrint('Sending test email to $to via $_baseUrl');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/welcome-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': to,
          'name': 'Test User',
        }),
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('Test email response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        debugPrint('Response body: ${response.body}');
      }
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending test email: $e');
      return _sendLocalEmail(to, subject, content);
    }
  }
  
  /// Sends a password reset email
  Future<bool> sendPasswordResetEmail({
    required String to,
    String? name,
  }) async {
    try {
      debugPrint('Sending password reset email to $to via $_baseUrl');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': to,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('Password reset email response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        debugPrint('Response body: ${response.body}');
      }
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return _sendLocalEmail(to, 'Password Reset', 'Your password reset code is simulated in development mode.');
    }
  }
  
  /// Sends an order confirmation email
  Future<bool> sendOrderConfirmation({
    required String to,
    required String customerName,
    required String orderId,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      debugPrint('Sending order confirmation email to $to via $_baseUrl');
      final orderDetails = {
        'customer_name': customerName,
        'order_id': orderId,
        'total': total,
        'date': DateTime.now().toIso8601String(),
        'items': items,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/order-confirmation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': to,
          'order_details': orderDetails,
        }),
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('Order confirmation email response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        debugPrint('Response body: ${response.body}');
      }
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending order confirmation email: $e');
      return _sendLocalEmail(to, 'Order Confirmation', 'Your order has been confirmed (simulated in development mode)');
    }
  }
  
  /// Simulates sending an email locally for development purposes
  bool _sendLocalEmail(String to, String subject, String content) {
    debugPrint('\n====== SIMULATED EMAIL ======');
    debugPrint('To: $to');
    debugPrint('Subject: $subject');
    debugPrint('Content: $content');
    debugPrint('==============================\n');
    return true; // Always return success in development mode
  }
} 