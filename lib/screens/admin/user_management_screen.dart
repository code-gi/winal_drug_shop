import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _isLoading = false;
  String _roleFilter = 'all';
  final List<String> _roleOptions = ['all', 'admin', 'customer'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false).loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${user.name}"?'),
            if (user.orderCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Warning: This user has ${user.orderCount} orders associated with them.',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(user.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(int id) async {
    try {
      final result = await Provider.of<UserProvider>(context, listen: false)
          .deleteUser(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );

      if (result['success']) {
        await _loadUsers(); // Reload the list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    try {
      final result = await Provider.of<UserProvider>(context, listen: false)
          .toggleUserStatus(user);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'User ${user.isActive ? 'deactivated' : 'activated'} successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  List<User> _getFilteredUsers() {
    final userProvider = Provider.of<UserProvider>(context);
    final allUsers = userProvider.users;

    // First filter by role if needed
    final List<User> roleFiltered = _roleFilter == 'all'
        ? allUsers
        : allUsers.where((user) => user.role == _roleFilter).toList();

    // Then filter by search query if present
    if (_searchController.text.isEmpty) {
      return roleFiltered;
    }

    final query = _searchController.text.toLowerCase();
    return roleFiltered.where((user) {
      // Search by name
      if (user.name.toLowerCase().contains(query)) return true;

      // Search by email
      if (user.email.toLowerCase().contains(query)) return true;

      // Search by phone
      if (user.phone.toLowerCase().contains(query)) return true;

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: const Color(0xFF2A5298),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh Users',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Users',
                    hintText: 'Enter name, email or phone',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Search happens in _getFilteredUsers
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Role filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roleOptions.map((role) {
                      final isSelected = _roleFilter == role;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            role == 'all' ? 'All Users' : role.capitalize(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF2A5298),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _roleFilter = role;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF2A5298),
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF2A5298)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // User count
                Text(
                  '${filteredUsers.length} users found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 72,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_roleFilter != 'all' ||
                                _searchController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Try changing your filters',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserCard(context, user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    // Format date
    final formattedDate = DateFormat('MMM dd, yyyy').format(user.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(user: user),
            ),
          ).then((_) => _loadUsers());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User header with name and status
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getUserColor(user.role),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? user.name : 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(user.isActive, user.role),
                ],
              ),

              const Divider(height: 24),

              // User details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.phone_outlined,
                          'Phone',
                          user.phone.isNotEmpty ? user.phone : 'Not provided',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Joined',
                          formattedDate,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.shopping_bag_outlined,
                          'Orders',
                          user.orderCount.toString(),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.badge_outlined,
                          'Role',
                          user.role.capitalize(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      user.isActive
                          ? Icons.block_outlined
                          : Icons.check_circle_outline,
                      size: 16,
                    ),
                    label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          user.isActive ? Colors.red : Colors.green,
                      side: BorderSide(
                        color: user.isActive ? Colors.red : Colors.green,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailScreen(user: user),
                        ),
                      ).then((_) => _loadUsers());
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A5298).withOpacity(0.1),
                      foregroundColor: const Color(0xFF2A5298),
                      side: const BorderSide(color: Color(0xFF2A5298)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive, String role) {
    Color color;
    String label;

    if (isActive) {
      color = Colors.green;
      label = 'Active';
    } else {
      color = Colors.red;
      label = 'Inactive';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getUserColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
