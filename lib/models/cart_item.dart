import 'package:winal_front_end/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  int get totalPrice => product.price * quantity;
}
