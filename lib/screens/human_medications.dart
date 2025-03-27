import 'package:flutter/material.dart';

import 'package:winal_front_end/screens/medications_screen.dart'; // Adjust the import path as needed

void main() {
  runApp(const MedicineApp(userInitials: '', userEmail: ''));
}

class MedicineApp extends StatefulWidget {
  final String userInitials;
  final String userEmail;

  const MedicineApp({
    Key? key,
    required this.userInitials,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<MedicineApp> createState() => _MedicineAppState();
}

class _MedicineAppState extends State<MedicineApp> {
  // List of products with custom colors
  final List<Product> products = [
    Product(
      id: 1,
      name: 'Anti biotics',
      price: 5000,
      image: 'assets/images/antibiotics.jpeg',
      color: const Color(0xFFE0F7FA),
    ),
    Product(
      id: 2,
      name: 'Vitamin B',
      price: 8000,
      image: 'assets/images/vitamin.jpeg',
      color: const Color(0xFFFFF8E1),
    ),
    Product(
      id: 3,
      name: 'Steroids',
      price: 12000,
      image: 'assets/images/steroids.jpeg',
      color: const Color(0xFFFFECB3),
    ),
    Product(
      id: 4,
      name: 'Syrups',
      price: 10000,
      image: 'assets/images/SYRUP.jpeg',
      color: const Color(0xFFE1F5FE),
    ),
    Product(
      id: 5,
      name: 'Panadol tabs',
      price: 2000,
      image: 'assets/images/panadol.jpeg',
      color: const Color(0xFFE3F2FD),
    ),
    Product(
      id: 6,
      name: 'Eczema Creams',
      price: 35000,
      image: 'assets/images/ECZEMA CREAM.jpeg',
      color: const Color(0xFFF3E5F5),
    ),
  ];

  // Cart list
  final List<CartItem> cart = [];

  // Add a product to the cart
  void addToCart(Product product) {
    setState(() {
      final existingIndex = cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        cart[existingIndex].quantity += 1;
      } else {
        cart.add(CartItem(product: product));
      }
    });
  }

  // Calculate total price of items in cart
  int get totalPrice {
    return cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Total number of items in the cart
  int get totalItems {
    return cart.fold(0, (sum, item) => sum + item.quantity);
  }

  void navigateToCartPage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shopping Cart'),
        content: SizedBox(
          width: double.maxFinite,
          child: cart.isEmpty
              ? const Text('Your cart is empty')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200, // Fixed height for the list
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final item = cart[index];
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
                            'Shs.${totalPrice}',
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
          if (cart.isEmpty)
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
                    setState(() {
                      cart.clear();
                    });
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
                            content: Text('Checkout successful! Your order is being processed.'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          cart.clear();
                        });
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Human Meds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: Scaffold(
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
                if (totalItems > 0)
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
                        totalItems.toString(),
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
              .map((product) => MedicineCard(
                    imagePath: product.image,
                    title: product.name,
                    price: 'Shs.${product.price}',
                    color: product.color,
                    onAddToCart: () {
                      addToCart(product);
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
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final int price;
  final String image;
  final Color color;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.color,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class MedicineCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;
  final Color color;
  final VoidCallback onAddToCart;

  const MedicineCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.color,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              width: double.infinity,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.medication,
                            size: 60,
                            color: Colors.blue[300],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        color: Colors.blue[600],
                        onPressed: onAddToCart,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}