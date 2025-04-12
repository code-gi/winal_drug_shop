import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../utils/auth_service.dart';
import '../../../providers/category_provider.dart';
import 'medication_list_screen.dart';
import 'category_management_screen.dart';
import 'order_management_screen.dart';
import 'user_management_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminName;
  final String adminEmail;

  const AdminDashboardScreen({
    Key? key,
    required this.adminName,
    required this.adminEmail,
  }) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {
    'totalProducts': 0,
    'totalOrders': 0,
    'totalUsers': 0,
    'todaysRevenue': 0,
    'recentActivities': [],
    'lowStockItems': []
  };

  String baseUrl = 'http://192.168.43.57:5000';

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchData();
  }

  Future<void> _checkAuthAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthService.TOKEN_KEY);

    if (token == null) {
      _redirectToLogin();
      return;
    }

    // Verify token validity
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/token-debug'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _fetchDashboardData();
      } else {
        _redirectToLogin();
      }
    } catch (e) {
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AuthService.TOKEN_KEY);

      print('Fetching dashboard data...');
      print('Token available: ${token != null}');

      if (token == null) {
        print('No token found, redirecting to login');
        _redirectToLogin();
        return;
      }

      print('Making API request to: $baseUrl/api/admin/dashboard');
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (!mounted) return;
        final data = json.decode(response.body);
        print('Dashboard data received: $data');
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        print('Unauthorized access, redirecting to login');
        _redirectToLogin();
      } else {
        print('Error fetching dashboard data: ${response.reasonPhrase}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load dashboard data: ${response.reasonPhrase}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception while fetching dashboard data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading dashboard data: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Widget> _buildLowStockItems() {
    final items = _dashboardData['lowStockItems'] as List? ?? [];
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      widgets.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 20,
            ),
          ),
          title: Text(
            item['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Current stock: ${item['currentStock']} units',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          trailing: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminMedicationListScreen(),
                ),
              );
            },
            child: const Text('View'),
          ),
        ),
      );

      // Add divider if not the last item
      if (i < items.length - 1) {
        widgets.add(const Divider(height: 1));
      }
    }

    // If no items, show a message
    if (widgets.isEmpty) {
      widgets.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('No low stock items found'),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // Get current date for display
    final String currentDate =
        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF2A5298),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh dashboard',
            onPressed: _fetchDashboardData,
          ),
          // Notification icon
          IconButton(
            icon: const Stack(
              children: [
                Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          // Profile/settings dropdown
          PopupMenuButton(
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
                onTap: () {
                  Future.delayed(const Duration(seconds: 0), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  });
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
                onTap: () {
                  Future.delayed(const Duration(seconds: 0), () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2A5298),
              ),
            )
          : Container(
              color: const Color(0xFFF5F7FA),
              child: RefreshIndicator(
                onRefresh: _fetchDashboardData,
                color: const Color(0xFF2A5298),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Admin welcome header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A5298), Color(0xFF1E3C72)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    widget.adminName.isNotEmpty
                                        ? widget.adminName
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : "A",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2A5298),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back, ${widget.adminName}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentDate,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Dashboard summary cards
                      Row(
                        children: [
                          _buildSummaryCard(
                            context,
                            'Total Products',
                            _dashboardData['totalProducts']?.toString() ?? '0',
                            Icons.inventory_2_outlined,
                            const Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 16),
                          _buildSummaryCard(
                            context,
                            'Total Orders',
                            _dashboardData['totalOrders']?.toString() ?? '0',
                            Icons.shopping_cart_outlined,
                            const Color(0xFFF57C00),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildSummaryCard(
                            context,
                            'Total Users',
                            _dashboardData['totalUsers']?.toString() ?? '0',
                            Icons.people_outline,
                            const Color(0xFF5C6BC0),
                          ),
                          const SizedBox(width: 16),
                          _buildSummaryCard(
                            context,
                            'Today\'s Revenue',
                            'UGX ${NumberFormat("#,###").format(_dashboardData['todaysRevenue'] ?? 0)}',
                            Icons.attach_money_outlined,
                            const Color(0xFF26A69A),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Main section header
                      const Text(
                        'Administration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Administrative functions
                      Row(
                        children: [
                          Expanded(
                            child: _buildAdminCard(
                              context,
                              'Inventory',
                              'Manage medications and stock',
                              Icons.medication_outlined,
                              const Color(0xFF2196F3),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminMedicationListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAdminCard(
                              context,
                              'Categories',
                              'Manage product categories',
                              Icons.category_outlined,
                              const Color(0xFFFF9800),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CategoryManagementScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAdminCard(
                              context,
                              'Orders',
                              'View and manage customer orders',
                              Icons.shopping_cart_outlined,
                              const Color(0xFF4CAF50),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const OrderManagementScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAdminCard(
                              context,
                              'Users',
                              'Manage user accounts',
                              Icons.people_outline,
                              const Color(0xFF9C27B0),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UserManagementScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Insights section header
                      const Text(
                        'Insights & Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Insights and settings cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildAdminCard(
                              context,
                              'Analytics',
                              'View sales and performance metrics',
                              Icons.analytics_outlined,
                              const Color(0xFF00BCD4),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AnalyticsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAdminCard(
                              context,
                              'Settings',
                              'Configure system preferences',
                              Icons.settings_outlined,
                              const Color(0xFF607D8B),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const SizedBox(height: 24),

                      // Low Stock Items section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Low Stock Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2A5298),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_dashboardData['lowStockItems'] == null ||
                                (_dashboardData['lowStockItems'] as List)
                                    .isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text('No low stock items found'),
                                ),
                              )
                            else
                              ..._buildLowStockItems(),
                          ],
                        ),
                      ),

                      // Quick navigation buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Add Product'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminMedicationListScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(
                                      color: Color(0xFF2A5298)),
                                  foregroundColor: const Color(0xFF2A5298),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.view_list),
                                label: const Text('View Orders'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OrderManagementScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: const Color(0xFF2A5298),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
