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
  Future<void> loadCategories({String? type}) async {
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
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      for (String url in fallbackUrls) {
        try {
          print('🔄 Attempting to fetch categories from: $url');

          final Uri uri = Uri.parse('$url/api/categories/')
              .replace(queryParameters: queryParams);

          final response = await http.get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          print('📡 Categories response: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['categories'] != null) {
              _categories = (data['categories'] as List)
                  .map((item) => Category.fromJson(item))
                  .toList();

              print('✅ Successfully loaded ${_categories.length} categories');
              _isLoading = false;
              _error = null;
              notifyListeners();
              return; // Success, exit the fallback loop
            } else {
              print('❌ Categories data is null or malformed');
              // Continue to next server
            }
          } else {
            print('❌ Failed to load categories: ${response.statusCode}');
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
      print('❌ Error in loadCategories: ${e.toString()}');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new category
  Future<Map<String, dynamic>> addCategory({
    required String name,
    required String description,
    required File? imageFile,
    String type = 'human',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      // Base URL - should match your auth service
      String baseUrl = 'http://192.168.43.57:5000';

      // Create multipart request for handling file upload
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/categories/'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['type'] = type;

      // Add image file if it exists
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
      }

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var parsedResponse = json.decode(responseData);

      if (response.statusCode == 201) {
        await loadCategories(); // Reload categories
        return {'success': true, 'message': 'Category created successfully'};
      } else {
        return {
          'success': false,
          'message': parsedResponse['message'] ?? 'Failed to create category',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing category
  Future<Map<String, dynamic>> updateCategory(
    int categoryId, {
    required String name,
    required String description,
    File? imageFile,
    String? type,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      String baseUrl = 'http://192.168.43.57:5000';

      // Create multipart request for handling file upload
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/categories/$categoryId/'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      if (type != null) {
        request.fields['type'] = type;
      }

      // Add image file if it has changed
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
      }

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var parsedResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        await loadCategories(); // Reload categories
        return {'success': true, 'message': 'Category updated successfully'};
      } else {
        return {
          'success': false,
          'message': parsedResponse['message'] ?? 'Failed to update category',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a category
  Future<Map<String, dynamic>> deleteCategory(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final baseUrl = 'http://192.168.43.57:5000';
      final response = await http.delete(
        Uri.parse('$baseUrl/api/categories/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await loadCategories(); // Reload categories
        return {'success': true, 'message': 'Category deleted successfully'};
      } else {
        final responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete category',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
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
