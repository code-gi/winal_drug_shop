import 'package:flutter/material.dart';
import 'package:winal_front_end/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:winal_front_end/models/cart_item.dart';
import 'package:winal_front_end/utils/order_service.dart';
import 'package:winal_front_end/utils/distance_service.dart';
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
        if (result['data'] != null) {
          List<dynamic> ordersData = [];

          // Handle both possible response structures
          if (result['data'] is List) {
            ordersData = result['data'];
            developer.log('Backend returned orders as direct list');
          } else if (result['data'] is Map &&
              result['data']['orders'] != null) {
            ordersData = result['data']['orders'];
            developer.log('Backend returned orders inside data.orders');
          } else {
            developer.log(
                'Unexpected data structure: ${result['data'].runtimeType}');
            // Try to extract orders from the data structure
            if (result['data'] is Map) {
              final keys = (result['data'] as Map).keys.toList();
              developer.log('Available keys in data: $keys');

              // Look for any key that might contain orders
              for (final key in keys) {
                if ((result['data'][key] is List) &&
                    (result['data'][key] as List).isNotEmpty &&
                    (result['data'][key][0] is Map)) {
                  ordersData = result['data'][key];
                  developer.log('Found orders in key: $key');
                  break;
                }
              }
            }
          }

          developer.log('Received ${ordersData.length} orders from backend');

          if (ordersData.isNotEmpty) {
            // For debugging, log the structure of the first order
            developer.log('First order structure: ${ordersData[0]}');

            // Clear existing orders and replace with backend data
            _orders = ordersData.map((item) {
              return Order.fromMap(item);
            }).toList();

            // Save to local storage
            await saveOrdersToLocal();
            notifyListeners();
          } else {
            developer.log('No orders found in the response');
          }
        } else {
          developer.log('No data key in response');
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

    print('🔵 OrderProvider: Creating order for user: $_currentUserEmail');
    print('🔵 OrderProvider: Order items count: ${items.length}');
    print('🔵 OrderProvider: Total amount: $totalAmount');
    print('🔵 OrderProvider: Payment method: $paymentMethod');
    print('🔵 OrderProvider: Delivery address: $deliveryAddress');

    try {
      // Try to create order in backend first
      print('🔵 OrderProvider: Sending order to backend...');
      final result = await _orderService.createOrder(
        items: items,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
      );

      print('🔵 OrderProvider: Order creation result: ${result['success']}');

      if (result['success']) {
        // If backend call successful, create order with returned data
        final orderData = result['data']['order'];
        print(
            '🔵 OrderProvider: Backend order data received: ${json.encode(orderData)}');

        final String orderId = orderData['id']?.toString() ?? uuid.v4();
        print('🔵 OrderProvider: Using order ID: $orderId');

        final newOrder = Order(
          id: orderId,
          userEmail: _currentUserEmail!,
          items: items,
          totalAmount: totalAmount,
          paymentMethod: paymentMethod,
          deliveryAddress: deliveryAddress,
          orderDate: DateTime.parse(
              orderData['order_date'] ?? DateTime.now().toIso8601String()),
          status: orderData['status'] ?? 'pending',
          deliveryFee: 5000, // Explicitly include the delivery fee
        );

        print('🔵 OrderProvider: Created order object with ID: ${newOrder.id}');
        _orders.add(newOrder);
        await saveOrdersToLocal();

        _isLoading = false;
        notifyListeners();

        return newOrder;
      } else {
        // Enhanced error logging
        print(
            '❌ OrderProvider: Backend order creation failed: ${result['message']}');

        if (result.containsKey('status_code')) {
          print('❌ OrderProvider: Status code: ${result['status_code']}');
        }

        if (result.containsKey('response_body')) {
          print('❌ OrderProvider: Response body: ${result['response_body']}');
        }

        // Create local order as fallback
        print('🔶 OrderProvider: Falling back to local order creation');
        final newOrder = _createLocalOrder(
            items, totalAmount, paymentMethod, deliveryAddress);

        _isLoading = false;
        notifyListeners();

        return newOrder;
      }
    } catch (e) {
      print('❌ OrderProvider: Error in createOrder: ${e.toString()}');

      // Fallback to local creation if there's an exception
      print(
          '🔶 OrderProvider: Exception occurred, falling back to local order creation');
      final newOrder =
          _createLocalOrder(items, totalAmount, paymentMethod, deliveryAddress);

      _isLoading = false;
      _errorMessage = 'Could not connect to server. Order saved locally only.';
      notifyListeners();

      return newOrder;
    }
  }

  // Fallback method to create order locally if backend is unavailable
  Future<Order> _createLocalOrder(
    List<CartItem> items,
    int totalAmount,
    String paymentMethod,
    String deliveryAddress,
  ) async {
    print('🟠 OrderProvider: Creating local order fallback');

    // Use a fixed delivery fee for now
    const int deliveryFee = 5000; // Default delivery fee

    print('🟠 OrderProvider: Using delivery fee: UGX $deliveryFee');

    final newOrder = Order(
      id: uuid.v4(),
      userEmail: _currentUserEmail!,
      items: items,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      orderDate: DateTime.now(),
      status: 'pending',
      deliveryFee: deliveryFee, // Use the dynamically calculated fee
    );

    print('🟠 OrderProvider: Created local order with ID: ${newOrder.id}');
    _orders.add(newOrder);
    saveOrdersToLocal();

    return newOrder;
  }

  // Get orders for the current user
  List<Order> getUserOrders() {
    if (_currentUserEmail == null) {
      print('getUserOrders: currentUserEmail is null, returning empty list');
      return [];
    }

    print(
        'getUserOrders: Filtering ${_orders.length} orders for user: $_currentUserEmail');

    // Log each order's userEmail for debugging
    for (var i = 0; i < _orders.length; i++) {
      print('Order $i: id=${_orders[i].id}, userEmail=${_orders[i].userEmail}');
    }

    final userOrders = _orders.where((order) {
      // Check if the order belongs to current user by comparing emails
      bool isMatch =
          order.userEmail.toLowerCase() == _currentUserEmail!.toLowerCase();

      // If userEmail is a numeric string (meaning it's from the backend and is a user_id),
      // we should compare it differently
      if (!isMatch && order.userEmail.contains(RegExp(r'^[0-9]+$'))) {
        // This is likely a user_id from the backend
        print(
            'Order ${order.id} has numeric userEmail (user_id): ${order.userEmail}');

        // Here we could add additional checks if needed
        // For simplicity, we could just trust that all orders returned from the backend
        // belong to the current user, but this might not be appropriate in all cases
        isMatch = true;
      }

      return isMatch;
    }).toList();

    print('getUserOrders: Found ${userOrders.length} orders for current user');
    return userOrders;
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
