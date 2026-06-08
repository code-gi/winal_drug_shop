import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:winal_front_end/models/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/providers/cart_provider.dart';
import 'package:winal_front_end/providers/order_provider.dart';
import 'package:winal_front_end/utils/auth_provider.dart';
import 'package:winal_front_end/widgets/simple_map_placeholder.dart';
import 'package:winal_front_end/screens/delivery_map_screen.dart';
import 'package:winal_front_end/widgets/place_search_field.dart';
import 'dart:async';
import 'dart:developer' as developer;

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cart;
  final int totalPrice;

  const CheckoutScreen({
    Key? key,
    required this.cart,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Mobile Money',
    'Credit Card'
  ];
  final TextEditingController _whereToController = TextEditingController();
  final TextEditingController _whereFromController = TextEditingController();
  final double deliveryFee = 5000;
  bool _showMap = false; // Control map visibility

  // Google Maps variables - retained for compatibility but not actively used
  static const LatLng _winalDrugShop =
      LatLng(0.3025, 32.5539); // Approximate coordinates for Nateete, Kampala
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Set default pickup location
    _whereFromController.text = 'Winal Drug Shop, Nateete';
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: _winalDrugShop,
        infoWindow: const InfoWindow(title: 'Winal Drug Shop'),
      ),
    );
  }

  @override
  void dispose() {
    _whereToController.dispose();
    _whereFromController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalWithDelivery = widget.totalPrice + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your order',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Section
            const Text(
              'ORDER SUMMARY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item count header
                  Text(
                    '${widget.cart.length} item${widget.cart.length > 1 ? 's' : ''} in your cart',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(),
                  // List of items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cart.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              item.product.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported,
                                      size: 25),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Item details
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
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity} x UGX ${item.product.price}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Item subtotal
                          Text(
                            'UGX ${item.product.price * item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(),
                  // Subtotal
                  _buildOrderSummaryRow('Subtotal', 'UGX ${widget.totalPrice}'),
                  const SizedBox(height: 4),
                  // Delivery fee
                  _buildOrderSummaryRow('Delivery Fee', 'UGX $deliveryFee'),
                  const Divider(),
                  // Total
                  _buildOrderSummaryRow('Total', 'UGX $totalWithDelivery',
                      isTotal: true),
                ],
              ),
            ),

            const SizedBox(
                height: 20), // Map section with a toggle to hide/show
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'DELIVERY LOCATION',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: _showMap,
                  onChanged: (value) {
                    setState(() {
                      _showMap = value;
                    });
                  },
                ),
                // Add a button to open the dedicated map screen
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.blue),
                  tooltip: 'View full map',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryMapScreen(
                          pickupAddress: _whereFromController.text,
                          deliveryAddress: _whereToController.text.isEmpty
                              ? 'Please enter delivery address'
                              : _whereToController.text,
                          pickupLocation: _winalDrugShop,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Map (shown conditionally) - Using our new SimpleMapPlaceholder
            if (_showMap) ...[
              const SizedBox(height: 12),
              SimpleMapPlaceholder(
                storeAddress: _whereFromController.text,
                deliveryAddress: _whereToController.text.isNotEmpty
                    ? _whereToController.text
                    : null,
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              'WHERE TO?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _whereToController,
              decoration: InputDecoration(
                hintText: 'Enter delivery address',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (text) {
                if (_showMap)
                  setState(() {}); // Refresh the map when address changes
              },
            ),

            const SizedBox(height: 16),
            const Text(
              'WHERE FROM?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _whereFromController,
              decoration: InputDecoration(
                hintText: 'Enter pickup address',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (text) {
                if (_showMap)
                  setState(() {}); // Refresh the map when address changes
              },
            ),

            const SizedBox(height: 16),
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              hint: const Text('Select payment method'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue;
                });
              },
              items:
                  _paymentMethods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _handlePlaceOrder(context, totalWithDelivery.toInt()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlaceOrder(BuildContext context, int totalAmount) async {
    // Validate inputs
    if (_whereToController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    // Get providers
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Log order information
    print('🛒 CheckoutScreen: Placing order with ${widget.cart.length} items');
    print('🛒 CheckoutScreen: Total amount: $totalAmount');
    print('🛒 CheckoutScreen: Payment method: $_selectedPaymentMethod');
    print('🛒 CheckoutScreen: Delivery address: ${_whereToController.text}');
    print(
        '🛒 CheckoutScreen: Auth status: ${authProvider.isAuthenticated ? 'Authenticated' : 'Not authenticated'}');

    // Show a loading indicator while processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing your order...'),
            ],
          ),
        );
      },
    );

    // Create a timeout to prevent getting stuck indefinitely
    Timer? timeoutTimer;
    timeoutTimer = Timer(const Duration(seconds: 30), () {
      // Handle timeout case - close dialog and show error
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close the loading dialog
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order processing timed out. Please try again.'),
          duration: Duration(seconds: 5),
        ),
      );
      print('❌ CheckoutScreen: Order placement timed out after 30 seconds');
    });

    // Refresh authentication status to ensure it's current
    if (authProvider.isAuthenticated) {
      try {
        print('🛒 CheckoutScreen: Starting order creation process...');
        // Create a new order
        final order = await orderProvider.createOrder(
          items: widget.cart,
          totalAmount: totalAmount,
          paymentMethod: _selectedPaymentMethod!,
          deliveryAddress: _whereToController.text,
        );

        // Cancel the timeout timer since we got a response
        timeoutTimer.cancel();
        print(
            '🛒 CheckoutScreen: Order creation completed with ID: ${order.id}');

        // Safety check if context is still valid
        if (!mounted) return;

        // Close the loading dialog if it's still showing
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        if (order.id.startsWith('error')) {
          // Show error message if order creation fails
          print('❌ CheckoutScreen: Order creation failed with error ID');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error connecting to server. Please try again.'),
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }

        // Only clear the cart after successful order creation
        print('🛒 CheckoutScreen: Clearing cart after successful order');
        cartProvider.clearCart();

        // Show order success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Order Successful!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your order has been placed successfully.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order #: ${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Payment Method: $_selectedPaymentMethod',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Delivery Address: ${_whereToController.text}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Amount: UGX $totalAmount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to Orders page
                    Navigator.pushNamed(context, '/orders');
                  },
                  child: const Text('View Orders'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Return to main screen after order
                    final userEmail = authProvider.userData?['email'] ?? '';
                    final firstName =
                        authProvider.userData?['first_name'] ?? '';
                    final lastName = authProvider.userData?['last_name'] ?? '';
                    final initials = firstName.isNotEmpty && lastName.isNotEmpty
                        ? '${firstName[0]}${lastName[0]}'
                        : '';

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard',
                      (route) => false,
                      arguments: {
                        'userEmail': userEmail,
                        'userInitials': initials,
                      },
                    );
                  },
                  child: const Text('Continue Shopping'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        // Cancel the timeout timer
        timeoutTimer.cancel();

        // Safety check if context is still valid
        if (!mounted) return;

        // Close the loading dialog if it's still showing
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        // Show detailed error message if order creation fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $error'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _handlePlaceOrder(context, totalAmount);
              },
            ),
          ),
        );
      }
    } else {
      // Cancel the timeout timer
      timeoutTimer.cancel();

      // Safety check if context is still valid
      if (!mounted) return;

      // Close the loading dialog if it's still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Handle not authenticated case
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to place an order'),
          duration: Duration(seconds: 3),
        ),
      );
      // Navigate to login screen
      Navigator.of(context).pushNamed('/login');
    }
  }

  Widget _buildOrderSummaryRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
