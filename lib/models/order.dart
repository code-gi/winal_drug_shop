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

  // Create order from a map (from SharedPreferences)
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userEmail: map['userEmail'],
      items: (map['items'] as List).map((item) {
        final product = Product(
          id: item['product']['id'],
          name: item['product']['name'],
          description: item['product']['description'] ?? '',
          price: item['product']['price'],
          image: item['product']['image'],
          type: item['product']['type'] ?? '',
        );

        return CartItem(
          product: product,
          quantity: item['quantity'],
        );
      }).toList(),
      totalAmount: map['totalAmount'],
      paymentMethod: map['paymentMethod'],
      deliveryAddress: map['deliveryAddress'],
      orderDate: DateTime.parse(map['orderDate']),
      status: map['status'],
    );
  }
}
