import 'package:flutter/material.dart';
import 'package:winal_front_end/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:winal_front_end/models/cart_item.dart';
import 'package:winal_front_end/utils/order_service.dart';
import 'dart:developer' as developer;

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  String? _currentUserEmail;
  final uuid = Uuid();
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor to initialize orders
  OrderProvider() {
    loadOrders();
  }

  // Set current user email and load their orders
  void setCurrentUser(String? email) {
    _currentUserEmail = email;
    loadOrders();
  }

  // Load orders from both local storage and backend
  Future<void> loadOrders() async {
    if (_currentUserEmail == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First, load from local storage for immediate display
      await _loadOrdersFromLocal();

      // Then, try to fetch the latest from the backend
      await _fetchOrdersFromBackend();
    } catch (e) {
      developer.log('Error loading orders', error: e);
      _errorMessage = 'Error loading orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load orders from SharedPreferences
  Future<void> _loadOrdersFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('orders_${_currentUserEmail}');

      if (ordersJson != null) {
        final List<dynamic> ordersData = json.decode(ordersJson);
        _orders = ordersData.map((item) => Order.fromMap(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error loading orders from local', error: e);
    }
  }

  // Fetch orders from backend
  Future<void> _fetchOrdersFromBackend() async {
    try {
      final result = await _orderService.getOrders();
      developer.log('Order fetch result: ${result['success']}');

      if (result['success']) {
        // If backend call successful, replace local orders with backend data
        if (result['data']['orders'] != null) {
          final List<dynamic> ordersData = result['data']['orders'];
          developer.log('Received ${ordersData.length} orders from backend');

          // Clear existing orders and replace with backend data
          _orders = ordersData.map((item) {
            // Log the structure of an item to debug
            developer.log('Order item structure: ${item.keys.join(', ')}');
            return Order.fromMap(item);
          }).toList();

          // Save to local storage
          await saveOrdersToLocal();
          notifyListeners();
        } else {
          developer.log(
              'No orders key in response: ${result['data'].keys.join(', ')}');
        }
      } else {
        developer
            .log('Error fetching orders from backend: ${result['message']}');
        // If backend fails, we still have the local data loaded
      }
    } catch (e) {
      developer.log('Error in _fetchOrdersFromBackend', error: e);
      // Keep using local data if backend fetch fails
    }
  }

  // Save orders to SharedPreferences
  Future<void> saveOrdersToLocal() async {
    if (_currentUserEmail == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = _orders.map((order) => order.toMap()).toList();
      await prefs.setString(
          'orders_${_currentUserEmail}', json.encode(ordersData));
    } catch (e) {
      developer.log('Error saving orders to local', error: e);
    }
  }

  // Create a new order - now attempts to save to backend first
  Future<Order> createOrder({
    required List<CartItem> items,
    required int totalAmount,
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    if (_currentUserEmail == null) {
      throw Exception('User not logged in');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to create order in backend first
      final result = await _orderService.createOrder(
        items: items,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
      );

      if (result['success']) {
        // If backend call successful, create order with returned data
        final orderData = result['data']['order'];
        final newOrder = Order(
          id: orderData['id'] ?? uuid.v4(), // Use backend ID if available
          userEmail: _currentUserEmail!,
          items: items,
          totalAmount: totalAmount,
          paymentMethod: paymentMethod,
          deliveryAddress: deliveryAddress,
          orderDate: DateTime.parse(
              orderData['order_date'] ?? DateTime.now().toIso8601String()),
          status: orderData['status'] ?? 'pending',
        );

        _orders.add(newOrder);
        await saveOrdersToLocal();

        _isLoading = false;
        notifyListeners();

        return newOrder;
      } else {
        // If backend call fails, create local order as fallback
        developer.log(
            'Backend order creation failed, creating locally: ${result['message']}');

        final newOrder = _createLocalOrder(
            items, totalAmount, paymentMethod, deliveryAddress);

        _isLoading = false;
        notifyListeners();

        return newOrder;
      }
    } catch (e) {
      developer.log('Error in createOrder', error: e);

      // Fallback to local creation if there's an exception
      final newOrder =
          _createLocalOrder(items, totalAmount, paymentMethod, deliveryAddress);

      _isLoading = false;
      _errorMessage = 'Could not connect to server. Order saved locally only.';
      notifyListeners();

      return newOrder;
    }
  }

  // Fallback method to create order locally if backend is unavailable
  Order _createLocalOrder(
    List<CartItem> items,
    int totalAmount,
    String paymentMethod,
    String deliveryAddress,
  ) {
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
    saveOrdersToLocal();

    return newOrder;
  }

  // Get orders for the current user
  List<Order> getUserOrders() {
    if (_currentUserEmail == null) return [];
    return _orders
        .where((order) => order.userEmail == _currentUserEmail)
        .toList();
  }

  // Update order status - now attempts to update in backend first
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      // If the newStatus is 'cancelled', use the cancel endpoint
      if (newStatus.toLowerCase() == 'cancelled') {
        final result = await _orderService.cancelOrder(orderId);

        if (!result['success']) {
          developer
              .log('Failed to cancel order on backend: ${result['message']}');
        }
      }

      // Update the local order regardless of backend result
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
        await saveOrdersToLocal();
      }
    } catch (e) {
      developer.log('Error updating order status', error: e);
      _errorMessage = 'Failed to update order status: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear user orders
  Future<void> clearOrders() async {
    _orders.clear();
    await saveOrdersToLocal();
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
