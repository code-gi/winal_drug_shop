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
  final int deliveryFee; // Add delivery fee field

  Order({
    required this.id,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.orderDate,
    required this.status,
    this.deliveryFee = 5000, // Default delivery fee is 5000
  });

  // Calculate subtotal (total amount minus delivery fee)
  int get subtotal => totalAmount - deliveryFee;

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
      'deliveryFee':
          deliveryFee, // Include delivery fee when saving to local storage
    };
  }

  // Create order from a map (from SharedPreferences or backend)
  factory Order.fromMap(Map<String, dynamic>? map) {
    try {
      // Return a minimal valid object if map is null
      if (map == null) {
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

      // Handle backend response format which may differ from local storage format
      final String orderId = map['id']?.toString() ?? '';

      // The key issue: Get userEmail or convert user_id to userEmail if needed
      String userEmail;
      if (map.containsKey('userEmail')) {
        userEmail = map['userEmail'] ?? '';
      } else if (map.containsKey('user_email')) {
        userEmail = map['user_email'] ?? '';
      } else if (map.containsKey('user_id')) {
        // If we only have user_id from backend, use it as userEmail
        // This ensures the orders will be filtered correctly in getUserOrders()
        userEmail = map['user_id'].toString();
        print('⚠️ Converting user_id to userEmail: $userEmail');
      } else {
        userEmail = '';
      }

      // Debug the incoming map
      print('Creating Order from map with ID: $orderId, userEmail: $userEmail');
      print('Map keys: ${map.keys.toList()}');
      // Handle different items structure depending on source
      List<CartItem> orderItems = [];

      // Backend format typically has 'items' as a list
      if (map['items'] != null) {
        try {
          orderItems = (map['items'] as List).map((item) {
            if (item is! Map<String, dynamic>) {
              print('Item is not a Map: $item');
              return CartItem(
                product: Product(
                  id: 0,
                  name: 'Unknown Product',
                  description: '',
                  price: 0,
                  image: 'assets/images/panadol.jpeg',
                  type: 'unknown',
                ),
                quantity: 1,
              );
            }

            // Enhanced backend format handling
            if (item.containsKey('product_id') || item.containsKey('item_id')) {
              // Backend format
              final productId = int.tryParse(item['product_id']?.toString() ??
                      item['item_id']?.toString() ??
                      '0') ??
                  0;

              final name = item['name'] ?? 'Product';
              final description = item['description'] ?? '';
              final price =
                  double.tryParse(item['price']?.toString() ?? '0')?.toInt() ??
                      0;
              final type = item['item_type'] ??
                  item['product_type'] ??
                  item['type'] ??
                  'medication';
              final quantity =
                  int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

              final product = Product(
                id: productId,
                name: name,
                description: description,
                price: price,
                image: 'assets/images/panadol.jpeg', // Default image
                type: type,
              );

              return CartItem(
                product: product,
                quantity: quantity,
              );
            } else if (item.containsKey('product')) {
              // Local storage format with nested product
              final productMap = item['product'] as Map<String, dynamic>;

              final product = Product(
                id: int.tryParse(productMap['id']?.toString() ?? '0') ?? 0,
                name: productMap['name'] ?? 'Product',
                description: productMap['description'] ?? '',
                price: double.tryParse(productMap['price']?.toString() ?? '0')
                        ?.toInt() ??
                    0,
                image: productMap['image'] ?? 'assets/images/panadol.jpeg',
                type: productMap['type'] ?? 'medication',
              );

              return CartItem(
                product: product,
                quantity:
                    int.tryParse(item['quantity']?.toString() ?? '1') ?? 1,
              );
            } else {
              // Unknown format - create a placeholder item
              print('Unknown item format: $item');
              return CartItem(
                product: Product(
                  id: 0,
                  name: 'Unknown Product',
                  description: '',
                  price: 0,
                  image: 'assets/images/panadol.jpeg',
                  type: 'unknown',
                ),
                quantity: 1,
              );
            }
          }).toList();
        } catch (e) {
          print('Error parsing order items: $e');
          print('Problematic items: ${map['items']}');
        }
      }

      // Various field mappings for different backend formats
      final int totalAmount = map['totalAmount'] != null
          ? (map['totalAmount'] is int
              ? map['totalAmount']
              : (map['totalAmount'] as double).toInt())
          : map['total_amount'] != null
              ? (map['total_amount'] is int
                  ? map['total_amount']
                  : (map['total_amount'] as double).toInt())
              : int.tryParse(map['total']?.toString() ?? '0') ?? 0;

      final paymentMethod = map['paymentMethod'] ?? map['payment_method'] ?? '';

      final deliveryAddress = map['deliveryAddress'] ??
          map['shipping_address'] ??
          map['delivery_address'] ??
          '';

      // Parse order date from string or use current date as fallback
      DateTime orderDate;
      try {
        if (map['orderDate'] == null &&
            map['order_date'] == null &&
            map['created_at'] == null) {
          orderDate = DateTime.now();
        } else {
          final dateString =
              map['orderDate'] ?? map['order_date'] ?? map['created_at'] ?? '';
          if (dateString is String && dateString.isNotEmpty) {
            orderDate = DateTime.parse(dateString);
          } else {
            orderDate = DateTime.now();
          }
        }
      } catch (e) {
        print('Error parsing date: $e');
        orderDate = DateTime.now();
      }

      final status = map['status'] ?? 'pending';

      // Get delivery fee from the map, or use the default value of 5000
      final int deliveryFee = map['deliveryFee'] != null
          ? (map['deliveryFee'] is int
              ? map['deliveryFee']
              : int.tryParse(map['deliveryFee'].toString()) ?? 5000)
          : map['delivery_fee'] != null
              ? (map['delivery_fee'] is int
                  ? map['delivery_fee']
                  : int.tryParse(map['delivery_fee'].toString()) ?? 5000)
              : 5000;

      return Order(
        id: orderId,
        userEmail: userEmail,
        items: orderItems,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        orderDate: orderDate,
        status: status,
        deliveryFee: deliveryFee,
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
