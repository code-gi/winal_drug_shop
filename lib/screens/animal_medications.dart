import 'package:flutter/material.dart';

import 'welcome_screen.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animal Meds',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 64, 108, 230), // Your blue
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 64, 108, 230), // Explicitly blue
        ),
      ),
      home: const AnimalMedsScreen(userEmail: '', userInitials: ''),
    );
  }
}

class Product {
  final int id;
  final String name;
  final int price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
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
class AnimalMedsScreen extends StatefulWidget {
  final String userEmail;
  final String userInitials;

  const AnimalMedsScreen({
    Key? key,
    required this.userEmail,
    required this.userInitials,
  }) : super(key: key);

  @override
  _AnimalMedsScreenState createState() => _AnimalMedsScreenState();
}

class _AnimalMedsScreenState extends State<AnimalMedsScreen> {
  final List<Product> products = [
    Product(
      id: 1,
      name: 'Ear drops',
      price: 30000,
      image: 'assets/images/EARDROPS .jpeg',
    ),
    Product(
      id: 2,
      name: 'Dewormer',
      price: 8000,
      image: 'assets/images/DEWORMER.jpg',
    ),
    Product(
      id: 3,
      name: 'Dog allergy',
      price: 12000,
      image: 'assets/images/allergy.jpeg',
    ),
    Product(
      id: 4,
      name: 'Infection treatment',
      price: 30000,
      image: 'assets/images/infection.jpeg',
    ),
    Product(
      id: 5,
      name: 'Diarrhea meds',
      price: 20000,
      image: 'assets/images/diarrhoea.jpeg',
    ),
    Product(
      id: 6,
      name: 'Pain killers',
      price: 15000,
      image: 'assets/images/painkillers.jpeg',
    ),
  ];

  final List<CartItem> cart = [];
  bool showCart = false;

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

  int get totalItems {
    return cart.fold(0, (sum, item) => sum + item.quantity);
  }

  int get totalPrice {
    return cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void toggleCart() {
    setState(() {
      showCart = !showCart;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 108, 230),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Only works if there's a previous route
          },
        ),
        title: const Text(
          'Animal Meds',
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
                onPressed: toggleCart,
              ),
              if (totalItems > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      totalItems.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onAddToCart: () => addToCart(product),
              );
            },
          ),
          if (showCart)
            Positioned(
              top: 0,
              right: 0,
              child: CartPopup(
                cart: cart,
                totalPrice: totalPrice,
                onClose: toggleCart,
              ),
            ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    product.image,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Text(
                            product.name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Shs.${product.price.toString()}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: AddButton(onPressed: onAddToCart),
          ),
        ],
      ),
    );
  }
}

class AddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AddButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  bool isAdding = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onPressed();
        setState(() {
          isAdding = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              isAdding = false;
            });
          }
        });
      },
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            isAdding ? '✓' : '+',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class CartPopup extends StatelessWidget {
  final List<CartItem> cart;
  final int totalPrice;
  final VoidCallback onClose;

  const CartPopup({
    Key? key,
    required this.cart,
    required this.totalPrice,
    required this.onClose,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Card(
        margin: const EdgeInsets.only(right: 10, top: 10),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: 300,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Cart',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              cart.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Your cart is empty'),
                    )
                  : Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: cart.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = cart[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Shs.${item.product.price} x ${item.quantity}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Shs.${item.product.price * item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
              if (cart.isNotEmpty) const Divider(),
              if (cart.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Total: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Shs.$totalPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (cart.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              cart: List.empty(),
                              totalPrice: totalPrice,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 64, 108, 230),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
