import 'package:flutter/material.dart';
import 'package:winal_front_end/models/product.dart';
import 'package:winal_front_end/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cart = [];
  String? _currentUserEmail; // Track the current user

  List<CartItem> get cart => _cart;

  int get totalItems {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  int get totalPrice {
    return _cart.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Constructor - load cart from storage
  CartProvider() {
    loadCart();
  }

  // Set the current user email - call this when user logs in
  void setCurrentUser(String? email) {
    _currentUserEmail = email;
    loadCart(); // Load the cart for this user
  }

  // Load cart from SharedPreferences
  Future<void> loadCart() async {
    if (_currentUserEmail == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_${_currentUserEmail}');

      if (cartJson != null) {
        final List<dynamic> cartData = json.decode(cartJson);
        _cart = cartData.map((item) {
          final product = Product(
            id: item['product']['id'],
            name: item['product']['name'],
            description: item['product']['description'] ?? '',
            price: item['product']['price'],
            image: item['product']['image'],
          );

          return CartItem(
            product: product,
            quantity: item['quantity'],
          );
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  // Save cart to SharedPreferences
  Future<void> saveCart() async {
    if (_currentUserEmail == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _cart.map((item) {
        return {
          'product': {
            'id': item.product.id,
            'name': item.product.name,
            'description': item.product.description,
            'price': item.product.price,
            'image': item.product.image,
          },
          'quantity': item.quantity,
        };
      }).toList();

      await prefs.setString('cart_${_currentUserEmail}', json.encode(cartData));
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  void addToCart(Product product) {
    // Check if product already exists in cart
    final index = _cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // Product exists, increase quantity
      final item = _cart[index];
      _cart[index] = CartItem(
        product: item.product,
        quantity: item.quantity + 1,
      );
    } else {
      // Add new product to cart
      _cart.add(CartItem(
        product: product,
        quantity: 1,
      ));
    }

    saveCart();
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final item = _cart[index];
      if (item.quantity > 1) {
        // Decrease quantity
        _cart[index] = CartItem(
          product: item.product,
          quantity: item.quantity - 1,
        );
      } else {
        // Remove product from cart
        _cart.removeAt(index);
      }

      saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    saveCart();
    notifyListeners();
  }
}
