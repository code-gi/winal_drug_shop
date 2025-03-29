import 'package:flutter/material.dart';
import 'package:winal_front_end/screens/medications_screen.dart';
import 'package:winal_front_end/screens/health_tips_screen.dart';
import 'package:winal_front_end/screens/farm_activities_screen.dart';
import 'package:winal_front_end/screens/chat_screen.dart';
import 'package:winal_front_end/screens/call_screen.dart';
import 'package:winal_front_end/screens/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String userEmail;
  final String userInitials;

  const DashboardScreen({
    Key? key,
    required this.userEmail,
    required this.userInitials,
  }) : super(key: key);

  String getInitials(String email) {
    if (email.isEmpty) return "?";
    List<String> parts = email.split('@');
    return parts[0].substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          'Winal Drug Shop',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userInitials.isNotEmpty
                      ? userInitials
                      : getInitials(userEmail),
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Winal Drug Shop',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hello, ${userEmail.split('@')[0]}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We provide quality medications for both humans and animals.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCategoryCard(
                        context,
                        'Human Medications',
                        'assets/images/HUMAN 1.jpeg',
                        Colors.blue[100]!,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicationsScreen(
                                userEmail: userEmail,
                                userInitials: userInitials,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildCategoryCard(
                        context,
                        'Animal Medications',
                        'assets/images/CAT.jpeg',
                        Colors.green[100]!,
                        () {
                          Navigator.pushNamed(
                            context,
                            '/animal_medications',
                            arguments: {
                              'userEmail': userEmail,
                              'userInitials': userInitials,
                            },
                          );
                        },
                      ),
                      _buildCategoryCard(
                        context,
                        'Health Tips',
                        'assets/images/IMMUNITY.jpeg',
                        Colors.orange[100]!,
                        () {
                          Navigator.pushNamed(context, '/health_tips');
                        },
                      ),
                      _buildCategoryCard(
                        context,
                        'Farm Activities',
                        'assets/images/FARM VISITS.jpeg',
                        Colors.purple[100]!,
                        () {
                          Navigator.pushNamed(context, '/farm_activities');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        'Chat',
                        Icons.chat_bubble_outline,
                        Colors.green,
                        () {
                          Navigator.pushNamed(context, '/chat');
                        },
                      ),
                      _buildActionButton(
                        context,
                        'Call',
                        Icons.phone_outlined,
                        Colors.blue,
                        () {
                          Navigator.pushNamed(context, '/call');
                        },
                      ),
                      _buildActionButton(
                        context,
                        'About Us',
                        Icons.info_outline,
                        Colors.orange,
                        () {
                          Navigator.pushNamed(context, '/about_us');
                        },
                      ),
                      _buildActionButton(
                        context,
                        'Admin',
                        Icons.admin_panel_settings,
                        Colors.red,
                        () {
                          Navigator.pushNamed(
                            context,
                            '/admin',
                            arguments: {
                              'adminName': userEmail.split('@')[0],
                              'adminEmail': userEmail,
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String imagePath,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  imagePath,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
