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
    'https://winal-backend.onrender.com', // Primary cloud-hosted URL
    'http://192.168.43.57:5000', // Legacy mobile hotspot (backup)
    'http://localhost:5000', // Local development
    'http://10.0.2.2:5000' // Android emulator to host loopback
  ];

  // Add a variable to track if we're using cached data
  bool _usedCachedData = false;

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

  // Cache categories data in SharedPreferences
  Future<void> _cacheCategoriesData() async {
    try {
      if (_categories.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final categoriesJson =
          _categories.map((category) => category.toJson()).toList();
      await prefs.setString('cached_categories', json.encode(categoriesJson));
      await prefs.setInt(
          'categories_cache_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Error caching categories data: $e');
    }
  }

  // Load cached categories data
  Future<List<Category>?> _loadCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_categories');
      final cacheTime = prefs.getInt('categories_cache_time') ?? 0;

      // Check if cache is not too old (less than 1 hour)
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTime;
      if (cachedData != null && cacheAge < 3600000) {
        final List<dynamic> categoriesJson = json.decode(cachedData);
        return categoriesJson.map((data) => Category.fromJson(data)).toList();
      }
    } catch (e) {
      print('❌ Error loading cached categories: $e');
    }
    return null;
  }

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get usedCachedData => _usedCachedData;

  // Load categories from API with improved error handling
  Future<void> loadCategories([String? type]) async {
    _isLoading = true;
    _error = null;
    _usedCachedData = false;

    // Important: Only notify once at the beginning
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Try to load cached categories first for immediate display
      final cachedCategories = await _loadCachedCategories();
      if (cachedCategories != null && cachedCategories.isNotEmpty) {
        _categories = type != null
            ? cachedCategories.where((c) => c.type == type).toList()
            : cachedCategories;
        _usedCachedData = true;
        _isLoading = false;
        notifyListeners();
      }

      final result = await _tryUrls((baseUrl) async {
        // Build query parameters
        Map<String, String> queryParams = {};
        if (type != null && type.isNotEmpty) {
          queryParams['type'] = type;
        }

        final Uri uri = Uri.parse('$baseUrl/api/categories/')
            .replace(queryParameters: queryParams);

        // Add timeout to avoid waiting too long
        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          print('📡 Categories response: ${response.statusCode}');
          final List<dynamic> data = json.decode(response.body);
          _categories = data.map((item) => Category.fromJson(item)).toList();

          // Cache the successful response
          _cacheCategoriesData();
          return 'success';
        }
        return null;
      });

      if (result == null && !_usedCachedData) {
        _error = 'Failed to load categories from all available servers';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Notify once at the end to avoid multiple rebuilds
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
