import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/screens/medications_screen.dart';
import 'package:winal_front_end/models/product.dart';
import 'package:winal_front_end/providers/cart_provider.dart';
import 'package:winal_front_end/widgets/product_card.dart';

class HumanMedicationsScreen extends StatefulWidget {
  final String userInitials;
  final String userEmail;

  const HumanMedicationsScreen({
    Key? key,
    required this.userInitials,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<HumanMedicationsScreen> createState() => _HumanMedicationsScreenState();
}

class _HumanMedicationsScreenState extends State<HumanMedicationsScreen> {
  // List of products with custom colors
  final List<Product> products = [
    Product(
      id: 1,
      name: 'Anti biotics',
      price: 5000,
      image: 'assets/images/antibiotics.jpeg',
      color: const Color(0xFFE0F7FA),
      type: 'human',
    ),
    Product(
      id: 2,
      name: 'Vitamin B',
      price: 8000,
      image: 'assets/images/vitamin.jpeg',
      color: const Color(0xFFFFF8E1),
      type: 'human',
    ),
    Product(
      id: 3,
      name: 'Steroids',
      price: 12000,
      image: 'assets/images/steroids.jpeg',
      color: const Color(0xFFFFECB3),
      type: 'human',
    ),
    Product(
      id: 4,
      name: 'Syrups',
      price: 10000,
      image: 'assets/images/SYRUP.jpeg',
      color: const Color(0xFFE1F5FE),
      type: 'human',
    ),
    Product(
      id: 5,
      name: 'Panadol tabs',
      price: 2000,
      image: 'assets/images/panadol.jpeg',
      color: const Color(0xFFE3F2FD),
      type: 'human',
    ),
    Product(
      id: 6,
      name: 'Eczema Creams',
      price: 35000,
      image: 'assets/images/ECZEMA CREAM.jpeg',
      color: const Color(0xFFF3E5F5),
      type: 'human',
    ),
  ];

  void navigateToCartPage() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shopping Cart'),
        content: SizedBox(
          width: double.maxFinite,
          child: cartProvider.cart.isEmpty
              ? const Text('Your cart is empty')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200, // Fixed height for the list
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cartProvider.cart.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.cart[index];
                          return ListTile(
                            title: Text(item.product.name),
                            subtitle: Text('Shs.${item.product.price}'),
                            trailing: Text('x${item.quantity}'),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Shs.${cartProvider.totalPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          if (cartProvider.cart.isEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    cartProvider.clearCart();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Cart'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continue Shopping'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Checkout successful! Your order is being processed.'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                        cartProvider.clearCart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to MedicationsScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MedicationsScreen(
                  userEmail: widget.userEmail,
                  userInitials: widget.userInitials,
                ),
              ),
            );
          },
        ),
        title: const Text(
          'Human Meds',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: navigateToCartPage,
              ),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartProvider.totalItems.toString(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: products
            .map((product) => ProductCard(
                  product: product,
                  onAddToCart: () {
                    cartProvider.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        width: 280,
                      ),
                    );
                  },
                ))
            .toList(),
      ),
    );
  }
}
