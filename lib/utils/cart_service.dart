import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  // Base URL for the Flask backend API - now hosted on Render.com
  final String baseUrl = 'https://winal-backend.onrender.com';

  // Alternative server URLs to try if the primary one fails
  final List<String> fallbackUrls = [
    'https://winal-backend.onrender.com', // Primary cloud-hosted URL
    'http://192.168.43.57:5000', // Legacy mobile hotspot (backup)
    'http://localhost:5000', // Local development
    'http://10.0.2.2:5000' // Android emulator to host loopback
  ];

  // Function to fetch cart items from the backend
  Future<List<dynamic>> fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cart'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      return [];
    }
  }

  // Function to add an item to the cart
  Future<bool> addItemToCart(Map<String, dynamic> item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding item to cart: $e');
      return false;
    }
  }

  // Function to remove an item from the cart
  Future<bool> removeItemFromCart(String itemId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/cart/$itemId'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing item from cart: $e');
      return false;
    }
  }

  // Function to clear the cart
  Future<bool> clearCart() async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/cart'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}
