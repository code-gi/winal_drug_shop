import 'package:flutter/material.dart';
import 'package:winal_front_end/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:winal_front_end/models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  String? _currentUserEmail;
  final uuid = Uuid();

  List<Order> get orders => _orders;

  // Constructor to initialize orders
  OrderProvider() {
    loadOrders();
  }

  // Set current user email and load their orders
  void setCurrentUser(String? email) {
    _currentUserEmail = email;
    loadOrders();
  }

  // Load orders from SharedPreferences
  Future<void> loadOrders() async {
    if (_currentUserEmail == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('orders_${_currentUserEmail}');

      if (ordersJson != null) {
        final List<dynamic> ordersData = json.decode(ordersJson);
        _orders = ordersData.map((item) => Order.fromMap(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  // Save orders to SharedPreferences
  Future<void> saveOrders() async {
    if (_currentUserEmail == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = _orders.map((order) => order.toMap()).toList();
      await prefs.setString(
          'orders_${_currentUserEmail}', json.encode(ordersData));
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  // Create a new order
  Future<Order> createOrder({
    required List<CartItem> items,
    required int totalAmount,
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    if (_currentUserEmail == null) {
      throw Exception('User not logged in');
    }

    final newOrder = Order(
      id: uuid.v4(),
      userEmail: _currentUserEmail!,
      items: items,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      orderDate: DateTime.now(),
      status: 'pending',
    );

    _orders.add(newOrder);
    await saveOrders();
    notifyListeners();

    return newOrder;
  }

  // Get orders for the current user
  List<Order> getUserOrders() {
    if (_currentUserEmail == null) return [];
    return _orders
        .where((order) => order.userEmail == _currentUserEmail)
        .toList();
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      final order = _orders[index];
      final updatedOrder = Order(
        id: order.id,
        userEmail: order.userEmail,
        items: order.items,
        totalAmount: order.totalAmount,
        paymentMethod: order.paymentMethod,
        deliveryAddress: order.deliveryAddress,
        orderDate: order.orderDate,
        status: newStatus,
      );

      _orders[index] = updatedOrder;
      await saveOrders();
      notifyListeners();
    }
  }

  // Clear user orders (for testing or account deletion)
  Future<void> clearOrders() async {
    _orders.clear();
    await saveOrders();
    notifyListeners();
  }
}
