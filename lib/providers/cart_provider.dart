import 'package:flutter/material.dart';
import 'package:winal_front_end/models/product.dart';
import 'package:winal_front_end/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cart = [];

  List<CartItem> get cart => _cart;

  int get totalItems {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  int get totalPrice {
    return _cart.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
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

      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
