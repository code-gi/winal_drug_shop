import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:winal_front_end/models/order.dart';
import 'package:winal_front_end/models/cart_item.dart';
import 'package:winal_front_end/utils/distance_service.dart';

class OrderService {
  // Base URL for the Flask backend API - now hosted on Render.com
  final String baseUrl = 'https://winal-backend.onrender.com';

  // Alternative server URLs to try if the primary one fails
  final List<String> fallbackUrls = [
    'https://winal-backend.onrender.com', // Primary cloud-hosted URL
    'http://192.168.43.57:5000', // Legacy mobile hotspot (backup)
    'http://localhost:5000', // Local development
    'http://10.0.2.2:5000' // Android emulator to host loopback
  ];

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Create a new order in the backend
  Future<Map<String, dynamic>> createOrder({
    required List<CartItem> items,
    required int totalAmount,
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    try {
      // Enhanced logging
      print('⭐ Creating order with ${items.length} items, total: $totalAmount');
      print(
          '📝 Items detail: ${items.map((item) => "${item.product.name} x${item.quantity}").join(", ")}');

      final token = await _getToken();
      print('🔑 Auth token: ${token != null ? 'Found' : 'Missing'}');
      if (token != null) {
        print(
            '🔑 Token preview: ${token.substring(0, math.min(20, token.length))}...');
      }

      if (token == null) {
        print('❌ Failed to create order: No auth token');
        return {
          'success': false,
          'message': 'You need to be logged in to place an order',
        };
      }

      // Convert cart items to format expected by API
      final itemsData = items
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
                'type': item.product.type, // Add product type
                'name': item.product.name, // Add product name
              })
          .toList();

      // Prepare order data
      final orderData = {
        'items': itemsData,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'delivery_address': deliveryAddress,
      };

      print('📦 Order data: ${json.encode(orderData)}');

      // Try each server URL in sequence
      Map<String, dynamic> responseData = {};
      int responseCode = 0;
      String responseBody = '';
      bool success = false;

      for (String url in fallbackUrls) {
        try {
          print('🔄 Trying server URL: $url');

          // Make sure URL has trailing slash for orders endpoint
          final apiUrl = '$url/api/orders/';
          print('🔄 Using API URL: $apiUrl');

          final response = await http.post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(orderData),
          );

          responseCode = response.statusCode;
          responseBody = response.body;

          print(
              '📡 Response from $url: Code=$responseCode, Body length=${responseBody.length}');
          print('📡 Full response body: $responseBody');

          if (responseBody.isNotEmpty) {
            try {
              responseData = json.decode(responseBody);
              success = true;
              print('✅ Successfully connected to server: $url');
              print('✅ Response data: ${json.encode(responseData)}');
              break; // Stop trying other URLs if this one worked
            } catch (e) {
              print('❌ Error parsing response from $url: $e');
              continue; // Try next URL
            }
          }
        } catch (e) {
          print('❌ Failed to connect to server $url: $e');
          // Continue to next URL
        }
      }

      if (success && (responseCode == 200 || responseCode == 201)) {
        print('✅ Order created successfully');
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message'] ?? 'Failed to create order';
        print('❌ Order creation failed: $errorMessage (Code=$responseCode)');

        return {
          'success': false,
          'message': errorMessage,
          'status_code': responseCode,
          'response_body': responseBody,
        };
      }
    } catch (e) {
      print('❌ Exception in order creation: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error creating order: ${e.toString()}',
      };
    }
  }

  // Get all orders for the current user
  Future<Map<String, dynamic>> getOrders() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'You need to be logged in to view orders',
        };
      }

      // Make sure URL has trailing slash
      final apiUrl = '$baseUrl/api/orders/';
      print('🔄 Getting orders using URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Get orders response: ${response.statusCode}');

      if (response.body.isEmpty) {
        print('❌ Empty response from server when fetching orders');
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = json.decode(response.body);
      print('📡 Orders response data received');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        print(
            '❌ Failed to get orders: ${responseData['message'] ?? 'Unknown error'}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get orders',
        };
      }
    } catch (e) {
      print('❌ Get orders error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get a specific order
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'You need to be logged in to view order details',
        };
      }

      // Make sure URL has trailing slash
      final apiUrl = '$baseUrl/api/orders/$orderId/';
      print('🔄 Getting order details using URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Get order response: ${response.statusCode}');

      if (response.body.isEmpty) {
        print('❌ Empty response from server when fetching order details');
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        print(
            '❌ Failed to get order details: ${responseData['message'] ?? 'Unknown error'}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get order details',
        };
      }
    } catch (e) {
      print('❌ Get order error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Cancel an order
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'You need to be logged in to cancel an order',
        };
      }

      // Make sure URL has trailing slash
      final apiUrl = '$baseUrl/api/orders/$orderId/cancel/';
      print('🔄 Cancelling order using URL: $apiUrl');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Cancel order response: ${response.statusCode}');

      if (response.body.isEmpty) {
        print('❌ Empty response from server when cancelling order');
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        print(
            '❌ Failed to cancel order: ${responseData['message'] ?? 'Unknown error'}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      print('❌ Cancel order error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
