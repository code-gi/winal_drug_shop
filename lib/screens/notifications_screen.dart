import 'package:flutter/material.dart';
import 'medications_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Blue header with back arrow
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                // Back arrow
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications list - wrapped in Expanded so it takes remaining space
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Limited Exclusive notification
                  NotificationCard(
                    title: 'Limited Exclusive: Unmissable',
                    message: 'Get supplements at just UGX 800 per tablet. Dont miss out shop now',
                    date: 'March 15, 2025',
                    borderColor: Colors.blue[100]!,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Price Drop notification
                  NotificationCard(
                    title: 'Price Drop',
                    message: 'Save BIG ON antibiotics, shop now and dont miss out',
                    date: 'March 14, 2025',
                    borderColor: Colors.blue[100]!,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Happy new month notification
                  NotificationCard(
                    title: 'Happy new month',
                    message: 'Skip the traffic and shop with winal drug shop',
                    date: 'March 1, 2025',
                    borderColor: Colors.blue[100]!,
                  ),

                  const SizedBox(height: 12),
                  
                  // Health Update notification
                  NotificationCard(
                    title: 'Health Update: No Animal Disease Outbreaks',
                    message: 'As of March 17, 2025, no major animal disease outbreaks have been reported in Uganda. However, reductions in U.S. aid may impact malaria control, affecting both human and animal health.',
                    date: 'March 17, 2025',
                    borderColor: Colors.red[100]!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for notification cards
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String date;
  final Color borderColor;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.date,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title in blue
            Text(
              title,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            // Message
            Text(
              message,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            
            // Date
            Row(
              children: [
                const Text(
                  'Date: ',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}