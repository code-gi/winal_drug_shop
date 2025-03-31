import 'package:winal_front_end/models/cart_item.dart';
import 'package:winal_front_end/models/product.dart';

class Order {
  final String id;
  final String userEmail;
  final List<CartItem> items;
  final int totalAmount;
  final String paymentMethod;
  final String deliveryAddress;
  final DateTime orderDate;
  final String status; // "pending", "delivered", "cancelled"

  Order({
    required this.id,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.orderDate,
    required this.status,
  });

  // Convert order to a map for saving to SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'items': items
          .map((item) => {
                'product': {
                  'id': item.product.id,
                  'name': item.product.name,
                  'description': item.product.description,
                  'price': item.product.price,
                  'image': item.product.image,
                  'type': item.product.type,
                },
                'quantity': item.quantity,
              })
          .toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }

  // Create order from a map (from SharedPreferences or backend)
  factory Order.fromMap(Map<String, dynamic> map) {
    try {
      // Handle backend response format which may differ from local storage format
      final String orderId = map['id']?.toString() ?? '';
      final String userEmail = map['userEmail'] ?? map['user_email'] ?? '';

      // Handle different items structure depending on source
      List<CartItem> orderItems = [];

      if (map['items'] != null) {
        orderItems = (map['items'] as List).map((item) {
          // Check if this is coming from backend or local storage
          if (item.containsKey('product_id')) {
            // Backend format
            final product = Product(
              id: int.tryParse(item['product_id']?.toString() ?? '0') ??
                  0, // Convert to int
              name: item['name'] ?? 'Product',
              description: item['description'] ?? '',
              price: item['price'] ?? 0,
              image: 'assets/images/panadol.jpeg', // Default image
              type: item['product_type'] ?? 'medication',
            );

            return CartItem(
              product: product,
              quantity: item['quantity'] ?? 1,
            );
          } else {
            // Local storage format
            final product = Product(
              id: int.tryParse(item['product']['id']?.toString() ?? '0') ??
                  0, // Convert to int
              name: item['product']['name'] ?? '',
              description: item['product']['description'] ?? '',
              price: item['product']['price'] ?? 0,
              image: item['product']['image'] ?? 'assets/images/panadol.jpeg',
              type: item['product']['type'] ?? '',
            );

            return CartItem(
              product: product,
              quantity: item['quantity'] ?? 1,
            );
          }
        }).toList();
      }

      // Handle different field names between backend and local storage
      final totalAmount = map['totalAmount'] ?? map['total_amount'] ?? 0;
      final paymentMethod = map['paymentMethod'] ?? map['payment_method'] ?? '';
      final deliveryAddress = map['deliveryAddress'] ??
          map['shipping_address'] ??
          map['delivery_address'] ??
          '';

      // Parse order date from string or use current date as fallback
      DateTime orderDate;
      try {
        final dateString = map['orderDate'] ??
            map['order_date'] ??
            DateTime.now().toIso8601String();
        orderDate = DateTime.parse(dateString);
      } catch (e) {
        orderDate = DateTime.now();
      }

      final status = map['status'] ?? 'pending';

      return Order(
        id: orderId,
        userEmail: userEmail,
        items: orderItems,
        totalAmount: totalAmount is int
            ? totalAmount
            : int.tryParse(totalAmount.toString()) ?? 0,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        orderDate: orderDate,
        status: status,
      );
    } catch (e) {
      print('Error creating Order from map: $e');
      print('Problematic map: $map');

      // Return a minimal valid object as fallback
      return Order(
        id: 'error-${DateTime.now().millisecondsSinceEpoch}',
        userEmail: '',
        items: [],
        totalAmount: 0,
        paymentMethod: '',
        deliveryAddress: '',
        orderDate: DateTime.now(),
        status: 'error',
      );
    }
  }
}
