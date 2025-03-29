import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/models/product.dart';
import 'package:winal_front_end/models/cart_item.dart'; // Ensure correct import
import 'package:winal_front_end/providers/cart_provider.dart';
import 'package:winal_front_end/widgets/product_card.dart';
import 'checkout_screen.dart';

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
      id: 101,
      name: 'Ear drops',
      price: 30000,
      image: 'assets/images/EARDROPS .jpeg',
      color: const Color(0xFFE8EAF6),
      type: 'animal',
    ),
    Product(
      id: 102,
      name: 'Dewormer',
      price: 8000,
      image: 'assets/images/DEWORMER.jpg',
      color: const Color(0xFFE0F2F1),
      type: 'animal',
    ),
    Product(
      id: 103,
      name: 'Dog allergy',
      price: 12000,
      image: 'assets/images/allergy.jpeg',
      color: const Color(0xFFF1F8E9),
      type: 'animal',
    ),
    Product(
      id: 104,
      name: 'Infection treatment',
      price: 30000,
      image: 'assets/images/infection.jpeg',
      color: const Color(0xFFFCE4EC),
      type: 'animal',
    ),
    Product(
      id: 105,
      name: 'Diarrhea meds',
      price: 20000,
      image: 'assets/images/diarrhoea.jpeg',
      color: const Color(0xFFEDE7F6),
      type: 'animal',
    ),
    Product(
      id: 106,
      name: 'Pain killers',
      price: 15000,
      image: 'assets/images/painkillers.jpeg',
      color: const Color(0xFFFFF3E0),
      type: 'animal',
    ),
  ];

  bool showCart = false;

  void toggleCart() {
    setState(() {
      showCart = !showCart;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 108, 230),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
              if (cartProvider.totalItems > 0)
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
                      cartProvider.totalItems.toString(),
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
              );
            },
          ),
          if (showCart)
            Positioned(
              top: 0,
              right: 0,
              child: CartPopup(
                cart: cartProvider.cart,
                totalPrice: cartProvider.totalPrice,
                onClose: toggleCart,
              ),
            ),
        ],
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
                              cart: cart,
                              totalPrice: totalPrice,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 64, 108, 230),
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
