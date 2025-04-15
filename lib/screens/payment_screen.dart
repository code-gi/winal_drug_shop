import 'package:flutter/material.dart';
import 'package:winal_front_end/models/farm_activity.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> args;

  const PaymentScreen({Key? key, required this.args}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String _selectedPaymentMethod = 'Mobile Money';
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract payment information from args
    final paymentType = widget.args['type'] ?? 'order';
    final double amount = widget.args['amount'] is double
        ? widget.args['amount']
        : (widget.args['amount'] is int
            ? widget.args['amount'].toDouble()
            : 0.0);

    // Determine title and description based on payment type
    String title = 'Payment';
    String description = '';

    if (paymentType == 'appointment') {
      // Handle appointment payment
      final farmActivity = widget.args['farmActivity'] as FarmActivity;
      title = 'Appointment Payment';
      description =
          'Payment for ${farmActivity.name} (${farmActivity.price} UGX)';
    } else {
      // Handle order payment
      final orderId = widget.args['orderId'] ?? '';
      title = 'Order Payment';
      description = 'Payment for Order #$orderId';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment details card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          '${amount.toStringAsFixed(0)} UGX',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment methods
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Mobile Money option
            RadioListTile<String>(
              title: const Text('Mobile Money'),
              value: 'Mobile Money',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: Colors.blue,
            ),

            // Credit/Debit Card option
            RadioListTile<String>(
              title: const Text('Credit/Debit Card'),
              value: 'Credit/Debit Card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: Colors.blue,
            ),

            // Cash option
            RadioListTile<String>(
              title: const Text('Cash on Delivery/Service'),
              value: 'Cash',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: Colors.blue,
            ),

            const SizedBox(height: 24),

            // Payment form based on selected method
            if (_selectedPaymentMethod == 'Mobile Money') ...[
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              const Text(
                'You will receive a prompt on your phone to confirm payment.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ] else if (_selectedPaymentMethod == 'Credit/Debit Card') ...[
              // Credit card form would go here
              const Text('Credit card payment is coming soon!')
            ],

            const SizedBox(height: 32),

            // Pay button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        // Handle payment logic
                        _processPayment(context, paymentType);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context, String paymentType) {
    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing with a delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful'),
          content: Text(paymentType == 'appointment'
              ? 'Your appointment has been confirmed.'
              : 'Your order has been confirmed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
