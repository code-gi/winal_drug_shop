import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:winal_front_end/models/order.dart';
import 'package:winal_front_end/models/cart_item.dart';

class OrderService {
  // Base URL for the Flask backend API - should match your auth_service.dart
  final String baseUrl = 'http://192.168.43.57:5000';

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
      final token = await _getToken();

      if (token == null) {
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
              })
          .toList();

      // Prepare order data
      final orderData = {
        'items': itemsData,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'delivery_address': deliveryAddress,
      };

      // Make API call
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(orderData),
      );

      developer.log('Create order response: ${response.statusCode}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      developer.log('Create order error', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
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

      final response = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Get orders response: ${response.statusCode}');

      if (response.body.isEmpty) {
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
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get orders',
        };
      }
    } catch (e) {
      developer.log('Get orders error', error: e);
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

      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Get order response: ${response.statusCode}');

      if (response.body.isEmpty) {
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
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get order details',
        };
      }
    } catch (e) {
      developer.log('Get order error', error: e);
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

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/$orderId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Cancel order response: ${response.statusCode}');

      if (response.body.isEmpty) {
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
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      developer.log('Cancel order error', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
