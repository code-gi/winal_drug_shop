import 'package:flutter/material.dart';
import 'dynamic_medications.dart';
import 'call_screen.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/providers/cart_provider.dart';

class MedicationsScreen extends StatefulWidget {
  final String userEmail;
  final String userInitials;

  const MedicationsScreen({
    Key? key,
    required this.userEmail,
    required this.userInitials,
  }) : super(key: key);

  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const CallScreen()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ChatScreen()));
    } else if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const NotificationsScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String getInitials(String email) {
    if (email.isEmpty) return "?";
    List<String> parts = email.split('@');
    return parts[0].substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
                gradient: LinearGradient(
                  colors: [Colors.blue, Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      getInitials(widget.userEmail),
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.userEmail,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('My Cart'),
              trailing: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return cartProvider.totalItems > 0
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartProvider.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cart');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/orders');
              },
            ),
            // Adding My Appointments list tile
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('My Appointments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my_appointments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/faqs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/feedback');
              },
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety),
              title: const Text('Health Tips'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/health_tips');
              },
            ),
            // Added Farm Activities to the drawer
            ListTile(
              leading: const Icon(Icons.agriculture),
              title: const Text('Farm Activities'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/farm_activities');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about_us');
              },
            ),
            // Admin Dashboard option
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/admin',
                  arguments: {
                    'adminName': widget.userEmail.split('@')[0],
                    'adminEmail': widget.userEmail,
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          "Medications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return cartProvider.totalItems > 0
                      ? Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartProvider.totalItems}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Text(
                getInitials(widget.userEmail),
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(25),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.2),
              //         spreadRadius: 1,
              //         blurRadius: 5,
              //         offset: const Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: TextField(
              //     decoration: InputDecoration(
              //       hintText: 'Search medications...',
              //       border: InputBorder.none,
              //       icon: const Icon(Icons.search, color: Colors.blue),
              //       suffixIcon: IconButton(
              //         icon: const Icon(Icons.filter_list, color: Colors.blue),
              //         onPressed: () {
              //           // Filter functionality would go here
              //         },
              //       ),
              //     ),
              //   ),
              // ),

              const SizedBox(height: 25),

              const Text(
                "Categories",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),

              const SizedBox(height: 15),

              _buildCategoryItem(
                "Animal Medications",
                "assets/images/CAT 7.jpeg",
                context,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DynamicMedicationsScreen(
                        userEmail: widget.userEmail,
                        userInitials: getInitials(widget.userEmail),
                        medicationType: "animal",
                        screenTitle: "Animal Medications",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _buildCategoryItem(
                "Human Medications",
                "assets/images/HUMAN 1.jpeg",
                context,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DynamicMedicationsScreen(
                        userEmail: widget.userEmail,
                        userInitials: getInitials(widget.userEmail),
                        medicationType: "human",
                        screenTitle: "Human Medications",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              const Text(
                "Popular Categories",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),

              const SizedBox(height: 15),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPopularCategoryItem(
                        "Antibiotics", "assets/images/antibiotics.jpeg"),
                    _buildPopularCategoryItem(
                        "Painkillers", "assets/images/painkillers.jpeg"),
                    _buildPopularCategoryItem(
                        "Vitamins", "assets/images/vitamin.jpeg"),
                    _buildPopularCategoryItem(
                        "Allergy", "assets/images/allergy.jpeg"),
                    _buildPopularCategoryItem(
                        "Infection", "assets/images/infection.jpeg"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: "Call"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notifications"),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String imagePath,
      BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCategoryItem(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Handle category tap
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.asset(
                imagePath,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
