import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load users from API
  Future<void> loadUsers({String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Base URL - should match your auth service
      String baseUrl = 'http://192.168.43.57:5000';

      // Alternative server URLs to try if the primary one fails
      List<String> fallbackUrls = [
        'http://192.168.43.57:5000', // Primary IP (mobile hotspot)
        'http://localhost:5000', // Local development
        'http://10.0.2.2:5000' // Android emulator to host loopback
      ];

      // Build query parameters
      Map<String, String> queryParams = {};
      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }

      for (String url in fallbackUrls) {
        try {
          print('🔄 Attempting to fetch users from: $url');

          final Uri uri = Uri.parse('$url/api/users/')
              .replace(queryParameters: queryParams);

          final response = await http.get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          print('📡 Users response: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['users'] != null) {
              _users = (data['users'] as List)
                  .map((item) => User.fromJson(item))
                  .toList();

              print('✅ Successfully loaded ${_users.length} users');
              _isLoading = false;
              _error = null;
              notifyListeners();
              return; // Success, exit the fallback loop
            } else {
              print('❌ Users data is null or malformed');
              // Continue to next server
            }
          } else {
            print('❌ Failed to load users: ${response.statusCode}');
            // Continue to next server
          }
        } catch (e) {
          print('❌ Error connecting to $url: ${e.toString()}');
          // Continue to next server
        }
      }

      // If we reach here, all servers failed
      _error = 'Failed to connect to server';
    } catch (e) {
      print('❌ Error in loadUsers: ${e.toString()}');
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

      final baseUrl = 'http://192.168.43.57:5000';
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

      final baseUrl = 'http://192.168.43.57:5000';
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
