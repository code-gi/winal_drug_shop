import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:winal_front_end/screens/dynamic_medications.dart';
import 'package:winal_front_end/models/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/providers/cart_provider.dart';
import 'package:winal_front_end/providers/order_provider.dart';
import 'package:winal_front_end/utils/auth_provider.dart';

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

  // Google Maps variables
  GoogleMapController? _mapController;
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
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_winalDrugShop, 15),
    );
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
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

            const SizedBox(height: 20),

            // Map section with a toggle to hide/show
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
              ],
            ),

            // Map (shown conditionally)
            if (_showMap) ...[
              const SizedBox(height: 12),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: const CameraPosition(
                      target: _winalDrugShop,
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                ),
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
                onPressed: () async {
                  if (_whereToController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter delivery address')),
                    );
                    return;
                  }
                  if (_selectedPaymentMethod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select a payment method')),
                    );
                    return;
                  }

                  // Get providers
                  final cartProvider =
                      Provider.of<CartProvider>(context, listen: false);
                  final orderProvider =
                      Provider.of<OrderProvider>(context, listen: false);
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);

                  // Refresh authentication status to ensure it's current
                  if (authProvider.isAuthenticated) {
                    try {
                      // Create a new order
                      final order = await orderProvider.createOrder(
                        items: widget.cart,
                        totalAmount: totalWithDelivery.toInt(),
                        paymentMethod: _selectedPaymentMethod!,
                        deliveryAddress: _whereToController.text,
                      );

                      // Only clear the cart after successful order creation
                      cartProvider.clearCart();

                      // Show order success dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 28),
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
                                  'Order #: ${order.id.substring(0, 8)}',
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
                                  'Total Amount: UGX $totalWithDelivery',
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
                                  final userEmail =
                                      authProvider.userData?['email'] ?? '';
                                  final firstName =
                                      authProvider.userData?['first_name'] ??
                                          '';
                                  final lastName =
                                      authProvider.userData?['last_name'] ?? '';
                                  final initials = firstName.isNotEmpty &&
                                          lastName.isNotEmpty
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
                      // Show error message if order creation fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error placing order: $error'),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  } else {
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
                },
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
