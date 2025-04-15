import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Could not launch $launchUri: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),

            // Header Section
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade200,
                          Colors.blue.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/WELCOME-removebg-preview.png',
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(),
                  const SizedBox(height: 20),
                  Text(
                    'Winal Drug Shop',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue.shade800,
                      letterSpacing: 1.1,
                    ),
                  ).animate().slideY(begin: 0.5, end: 0, duration: 500.ms),
                  const SizedBox(height: 10),
                  Text(
                    'Your Trusted Health Partner',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),

            // Contact Options
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Contact Options',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context,
                    phoneNumber: '0701550075',
                    icon: 'assets/images/AIRTEL-removebg-preview.png',
                    label: 'Customer Service',
                    onTap: () => _makePhoneCall('0701550075'),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context,
                    phoneNumber: '0704550075',
                    icon: 'assets/images/download__4_-removebg-preview.png',
                    label: 'Pharmacy Support',
                    onTap: () => _makePhoneCall('0704550075'),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context,
                    phoneNumber: '0775550075',
                    customIcon: Icons.emergency,
                    iconBackgroundColor: Colors.red.shade100,
                    iconColor: Colors.red,
                    label: 'Emergency Helpline',
                    onTap: () => _makePhoneCall('0775550075'),
                  ),
                ]),
              ),
            ),

            // Business Hours
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade50,
                        Colors.blue.shade100,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blue.shade800),
                          const SizedBox(width: 10),
                          Text(
                            'Business Hours',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const _BusinessHourRow(
                        day: 'Monday - Friday',
                        time: '8:00 AM - 8:00 PM',
                      ),
                      const SizedBox(height: 10),
                      const _BusinessHourRow(
                        day: 'Weekends',
                        time: '9:00 AM - 6:00 PM',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String phoneNumber,
    String? icon,
    IconData? customIcon,
    Color iconBackgroundColor = Colors.white,
    Color iconColor = Colors.blue,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.blue.shade50),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: icon != null
                  ? Center(
                      child: Image.asset(
                        icon,
                        width: 40,
                        height: 40,
                      ),
                    )
                  : Icon(
                      customIcon,
                      color: iconColor,
                      size: 35,
                    ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Colors.blue,
                size: 24,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0),
    );
  }
}

class _BusinessHourRow extends StatelessWidget {
  final String day;
  final String time;

  const _BusinessHourRow({
    required this.day,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
