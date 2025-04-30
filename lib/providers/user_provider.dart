import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  bool _usedCachedData = false;

  // Fallback URLs
  final List<String> _fallbackUrls = [
    // 'http://192.168.43.57:5000',
    // 'http://10.0.2.2:5000',
    // 'http://localhost:5000',
    'https://winal-backend.onrender.com'
  ];

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get usedCachedData => _usedCachedData;

  // Cache users data in SharedPreferences
  Future<void> _cacheUsersData(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = users.map((user) => user.toJson()).toList();
      await prefs.setString('cached_users', json.encode(usersJson));
      await prefs.setInt(
          'users_cache_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Error caching users data: $e');
    }
  }

  // Load cached users data
  Future<List<User>?> _loadCachedUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_users');
      final cacheTime = prefs.getInt('users_cache_time') ?? 0;

      // Check if cache is not too old (less than 1 hour)
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTime;
      if (cachedData != null && cacheAge < 3600000) {
        final List<dynamic> usersJson = json.decode(cachedData);
        return usersJson.map((data) => User.fromJson(data)).toList();
      }
    } catch (e) {
      print('❌ Error loading cached users: $e');
    }
    return null;
  }

  // Generate mock users for development purposes
  List<User> _generateMockUsers() {
    return [
      User(
        id: 1,
        email: 'admin@example.com',
        name: 'Admin User',
        role: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        phone: '+123456789',
        address: '123 Admin St',
        isActive: true,
        orderCount: 5,
      ),
      User(
        id: 2,
        email: 'customer@example.com',
        name: 'Example Customer',
        role: 'customer',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        phone: '+987654321',
        address: '456 Customer Ave',
        isActive: true,
        orderCount: 3,
      ),
      User(
        id: 3,
        email: 'inactive@example.com',
        name: 'Inactive User',
        role: 'customer',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        phone: '+111222333',
        address: '789 Inactive Blvd',
        isActive: false,
        orderCount: 1,
      ),
    ];
  }

  // Load users from API with improved error handling
  Future<void> loadUsers({String? role}) async {
    _isLoading = true;
    _error = null;
    _usedCachedData = false;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Try to load cached users first for immediate display
      final cachedUsers = await _loadCachedUsers();
      if (cachedUsers != null && cachedUsers.isNotEmpty) {
        _users = cachedUsers;
        _usedCachedData = true;
        notifyListeners();
      }

      bool success = false;

      for (String url in _fallbackUrls) {
        if (success) break;

        try {
          print('🔄 Attempting to fetch users from: $url');

          // Build query parameters
          Map<String, String> queryParams = {};
          if (role != null && role.isNotEmpty) {
            queryParams['role'] = role;
          }

          // Try different API endpoints - the correct one might be one of these
          final endpoints = [
            '/api/users/', // Original endpoint (404 error)
            '/api/admin/users/', // Try admin users endpoint
            '/api/admin/users', // Without trailing slash
            '/api/users', // Without trailing slash
            '/api/user/all/', // Alternative endpoint format
            '/api/users/list/' // Another alternative
          ];

          for (String endpoint in endpoints) {
            try {
              final uri = Uri.parse(url + endpoint)
                  .replace(queryParameters: queryParams);

              final response = await http.get(
                uri,
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              ).timeout(const Duration(
                  seconds: 5)); // Use a shorter timeout for multiple attempts

              print('📡 Trying $endpoint - Response: ${response.statusCode}');

              if (response.statusCode == 200) {
                try {
                  final responseData = json.decode(response.body);
                  List<dynamic> usersList;

                  // Fix the type error by correctly handling different response formats
                  if (responseData is Map<String, dynamic>) {
                    if (responseData['users'] != null &&
                        responseData['users'] is List) {
                      usersList = responseData['users'];
                    } else if (responseData['data'] != null &&
                        responseData['data'] is List) {
                      usersList = responseData['data'];
                    } else {
                      print('❌ No users list found in response: $responseData');
                      continue;
                    }
                  } else if (responseData is List) {
                    usersList = responseData;
                  } else {
                    print('❌ Unexpected response format: $responseData');
                    continue;
                  }

                  _users =
                      usersList.map((item) => User.fromJson(item)).toList();

                  print('✅ Successfully loaded ${_users.length} users');

                  // Cache the successful response
                  await _cacheUsersData(_users);

                  _error = null;
                  _usedCachedData = false;
                  success = true;
                  break; // Break the endpoint loop
                } catch (e) {
                  print('❌ Error parsing response: $e');
                  continue;
                }
              }
            } catch (e) {
              print('❌ Error with endpoint $endpoint: $e');
              continue;
            }
          }

          if (success) break; // Break the URL loop if successful
        } catch (e) {
          print('❌ Error connecting to $url: $e');
        }
      }

      // If all attempts failed and we don't have cached data, use mock data for development
      if (!success && !_usedCachedData) {
        print(
            '⚠️ Using mock user data since we could not connect to any backend');
        _users = _generateMockUsers();
        _error = 'Could not connect to server. Using sample data.';
      }
    } catch (e) {
      print('❌ Error in loadUsers: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user
  Future<Map<String, dynamic>> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final baseUrl = 'https://winal-backend.onrender.com';
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/${user.id}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await loadUsers(); // Reload users
        return {'success': true, 'message': 'User updated successfully'};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update user',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final baseUrl = 'https://winal-backend.onrender.com';
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await loadUsers(); // Reload users
        return {'success': true, 'message': 'User deleted successfully'};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete user',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle user active status
  Future<Map<String, dynamic>> toggleUserStatus(User user) async {
    final updatedUser = user.copyWith(isActive: !user.isActive);
    return await updateUser(updatedUser);
  }

  // Get a user by ID
  User? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get users by role
  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }
}
