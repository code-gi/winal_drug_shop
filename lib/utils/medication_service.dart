import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class MedicationService {
  // Base URL for the Flask backend API (change this to match your backend URL)
  final String baseUrl = 'http://192.168.43.57:5000';

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get all medications with optional filtering
  Future<Map<String, dynamic>> getMedications({
    String? medicationType,
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // Build the query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': pageSize.toString(),
      };

      // Add optional filters if provided
      if (medicationType != null) {
        queryParams['type'] = medicationType;
      }

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      // Create the URI with query parameters
      final uri = Uri.parse('$baseUrl/api/medications').replace(
        queryParameters: queryParams,
      );

      developer.log('Fetching medications from: $uri');

      // Make the HTTP request
      final response = await http.get(uri);

      developer.log('Response status code: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load medications');
      }
    } catch (e) {
      developer.log('Error fetching medications', error: e);
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get a specific medication by ID
  Future<Map<String, dynamic>> getMedicationById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/medications/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'medication': data};
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to load medication details');
      }
    } catch (e) {
      developer.log('Error fetching medication details', error: e);
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get all categories with optional filtering
  Future<List<dynamic>> getCategories({String? medicationType}) async {
    try {
      // Build query parameters if needed
      Map<String, String>? queryParams;
      if (medicationType != null) {
        queryParams = {'type': medicationType};
      }

      // Create the URI with query parameters
      final uri = Uri.parse('$baseUrl/api/categories').replace(
        queryParameters: queryParams,
      );

      // Make the HTTP request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      developer.log('Error fetching categories', error: e);
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Add medication to cart (requires authentication)
  Future<Map<String, dynamic>> addToCart(int medicationId, int quantity) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'You need to be logged in to add items to your cart',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/cart/items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'medication_id': medicationId,
          'quantity': quantity,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Added to cart successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add to cart',
        };
      }
    } catch (e) {
      developer.log('Error adding to cart', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Admin: Create a new medication
  Future<Map<String, dynamic>> createMedication(
      Map<String, dynamic> medicationData) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'You need to be logged in as an admin',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/medications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(medicationData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Medication created successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create medication',
        };
      }
    } catch (e) {
      developer.log('Error creating medication', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Admin: Update an existing medication
  Future<Map<String, dynamic>> updateMedication(
      int medicationId, Map<String, dynamic> medicationData) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'You need to be logged in as an admin',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/medications/$medicationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(medicationData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Medication updated successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update medication',
        };
      }
    } catch (e) {
      developer.log('Error updating medication', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Admin: Delete a medication
  Future<Map<String, dynamic>> deleteMedication(int medicationId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'You need to be logged in as an admin',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/medications/$medicationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Medication deleted successfully',
        };
      } else {
        final responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete medication',
        };
      }
    } catch (e) {
      developer.log('Error deleting medication', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
