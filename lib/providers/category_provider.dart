import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  final List<String> _fallbackUrls = [
    'http://192.168.43.57:5000', // Primary IP (mobile hotspot)
    'http://10.0.2.2:5000', // Android emulator to host loopback
    'http://localhost:5000', // Local development - lowest priority since it rarely works on mobile
  ];

  Future<String?> _tryUrls(
      Future<String?> Function(String baseUrl) apiCall) async {
    String? result;
    for (String url in _fallbackUrls) {
      try {
        result = await apiCall(url);
        if (result != null) {
          return result;
        }
      } catch (e) {
        print('❌ Error connecting to $url: $e');
        continue;
      }
    }
    return null;
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load categories from API
  Future<void> loadCategories([String? type]) async {
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

      final result = await _tryUrls((baseUrl) async {
        // Build query parameters
        Map<String, String> queryParams = {};
        if (type != null && type.isNotEmpty) {
          queryParams['type'] = type;
        }

        final Uri uri = Uri.parse('$baseUrl/api/categories/')
            .replace(queryParameters: queryParams);
        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          print('📡 Categories response: ${response.statusCode}');
          final List<dynamic> data = json.decode(response.body);
          _categories = data.map((item) => Category.fromJson(item)).toList();
          return 'success';
        }
        return null;
      });

      if (result == null) {
        _error = 'Failed to load categories from all available servers';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new category
  Future<void> addCategory(Category category) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final result = await _tryUrls((baseUrl) async {
        final response = await http.post(
          Uri.parse('$baseUrl/api/categories/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(category.toJson()),
        );

        if (response.statusCode == 201) {
          return 'success';
        }
        return null;
      });

      if (result == null) {
        throw Exception('Failed to add category on all available servers');
      }

      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Update an existing category
  Future<void> updateCategory(Category category) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final result = await _tryUrls((baseUrl) async {
        final response = await http.put(
          Uri.parse('$baseUrl/api/categories/${category.id}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(category.toJson()),
        );
        if (response.statusCode == 200) {
          return 'success';
        }
        if (response.statusCode == 403) {
          throw Exception('Admin access required');
        }
        if (response.statusCode == 404) {
          throw Exception('Category not found');
        }
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update category');
        return null;
      });

      if (result == null) {
        throw Exception('Failed to update category on all available servers');
      }

      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final result = await _tryUrls((baseUrl) async {
        final response = await http.delete(
          Uri.parse('$baseUrl/api/categories/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          return 'success';
        }
        if (response.statusCode == 403) {
          throw Exception('Admin access required');
        }
        if (response.statusCode == 404) {
          throw Exception('Category not found');
        }
        if (response.statusCode == 400) {
          final error = json.decode(response.body);
          throw Exception(
              error['message'] ?? 'Cannot delete category with medications');
        }
        throw Exception('Failed to delete category');
      });

      if (result == null) {
        throw Exception('Failed to delete category on all available servers');
      }

      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Get a category by ID
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get categories by type
  List<Category> getCategoriesByType(String type) {
    return _categories.where((category) => category.type == type).toList();
  }
}
