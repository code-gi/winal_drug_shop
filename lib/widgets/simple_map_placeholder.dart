import 'package:flutter/material.dart';

class SimpleMapPlaceholder extends StatelessWidget {
  final String storeAddress;
  final String? deliveryAddress;

  const SimpleMapPlaceholder({
    Key? key,
    required this.storeAddress,
    this.deliveryAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: SingleChildScrollView(
        // Added scrolling support
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Use min size instead of center alignment
          children: [
            Icon(Icons.map_outlined,
                size: 40, color: Colors.grey[400]), // Slightly smaller icon
            const SizedBox(height: 8), // Reduced spacing
            const Text(
              'Delivery Map',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6), // Reduced spacing
            const Text(
              'From:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(storeAddress, textAlign: TextAlign.center),
            const SizedBox(height: 6), // Reduced spacing
            const Text(
              'To:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              deliveryAddress ?? 'Please enter delivery address',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    deliveryAddress == null || deliveryAddress?.isEmpty == true
                        ? Colors.grey[400]
                        : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
