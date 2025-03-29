import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class AuthService {
  // Base URL for the Flask backend API
  // For Android emulator, use 10.0.2.2
  // For physical device on same network, use your computer's IP address
  final String baseUrl = 'http://192.168.43.57:5000';

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Remove token from SharedPreferences
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save the token if login successful
        if (responseData['access_token'] != null) {
          await _saveToken(responseData['access_token']);
          // Debug log to confirm token was saved
          developer.log(
              'Token saved: ${responseData['access_token'].substring(0, 10)}...');
        } else {
          developer.log('No access_token in response', error: responseData);
        }

        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      developer.log('Login error', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Register method
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String dateOfBirth,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'date_of_birth': dateOfBirth,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout method
  Future<void> logout() async {
    await _removeToken();
  }

  // Get user profile - improved version
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();
      developer.log(
          'Getting profile with token: ${token?.substring(0, 10) ?? "null"}...');

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      // First try the debug endpoint to check token status
      final debugResponse = await http.get(
        Uri.parse('$baseUrl/api/users/me/debug'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Profile debug response: ${debugResponse.statusCode}');
      developer.log('Profile debug body: ${debugResponse.body}');

      // Then attempt to get the actual profile
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Profile response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        // Try to refresh token and retry (only once)
        final refreshResult = await _tryRefreshToken();
        if (refreshResult['success']) {
          // Retry with new token
          final newToken = await _getToken();
          final retryResponse = await http.get(
            Uri.parse('$baseUrl/api/users/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $newToken',
            },
          );

          if (retryResponse.statusCode == 200) {
            return {
              'success': true,
              'data': json.decode(retryResponse.body),
            };
          }
        }

        // If retry fails or refresh fails, report auth failure
        await _removeToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      developer.log('Get profile error', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Try to refresh an expired token
  Future<Map<String, dynamic>> _tryRefreshToken() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No token to refresh',
        };
      }

      // This is a simplified token refresh - you might need to use a refresh token
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['access_token'] != null) {
          await _saveToken(responseData['access_token']);
          return {
            'success': true,
            'message': 'Token refreshed successfully',
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to refresh token',
      };
    } catch (e) {
      developer.log('Token refresh error', error: e);
      return {
        'success': false,
        'message': 'Error during token refresh: ${e.toString()}',
      };
    }
  }

  // Debug token issues
  Future<Map<String, dynamic>> debugToken() async {
    try {
      final token = await _getToken();
      developer.log('Debugging token: ${token?.substring(0, 10) ?? "null"}...');

      if (token == null) {
        return {
          'success': false,
          'message': 'No token available for debugging',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/token-debug'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Debug response status: ${response.statusCode}');
      developer.log('Debug response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': responseData,
      };
    } catch (e) {
      developer.log('Debug token error', error: e);
      return {
        'success': false,
        'message': 'Error debugging token: ${e.toString()}',
      };
    }
  }

  // Alternative profile endpoint for testing
  Future<Map<String, dynamic>> getProfileAlt() async {
    try {
      final token = await _getToken();
      developer.log(
          'Getting profile with token: ${token?.substring(0, 10) ?? "null"}...');

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Profile alt response status: ${response.statusCode}');

      // For debugging - print the raw response
      developer.log('Profile alt response body: ${response.body}');

      if (response.statusCode == 401) {
        // Token might be invalid or expired, try to handle by logging out
        await _removeToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      developer.log('Get profile alt error', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        }),
      );

      developer.log('Update profile response status: ${response.statusCode}');
      developer.log('Update profile response body: ${response.body}');

      if (response.statusCode == 401) {
        // Token might be invalid or expired
        await _removeToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      developer.log('Update profile error', error: e);
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
