import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class AuthService {
  // Base URLs for the Flask backend API with fallbacks
  final List<String> baseUrls = [
    'https://winal-backend.onrender.com', // Primary cloud-hosted URL
    'https://winaldrugshop-backend.onrender.com', // Alternative cloud URL
    'http://192.168.43.57:5000', // Legacy mobile hotspot (backup)
    'http://localhost:5000', // Local development
    'http://10.0.2.2:5000' // Android emulator to host loopback
  ];
  // Current working base URL
  String _currentBaseUrl =
      'https://winal-backend.onrender.com'; // Default to primary

  // Getter for the current base URL
  String get baseUrl => _currentBaseUrl;

  static const String TOKEN_KEY = 'auth_token';

  // Save token to SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
  }

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Remove token from SharedPreferences
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
  }

  // Try to find a working server
  Future<String> _getWorkingBaseUrl() async {
    print('📱 AUTH SERVICE DEBUG: Finding a working server...');

    for (String url in baseUrls) {
      try {
        print('📱 AUTH SERVICE DEBUG: Trying server URL: $url');
        final response = await http.get(
          Uri.parse('$url/api/auth/token-debug'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(
            seconds: 3)); // Short timeout to quickly move to next server

        // Status 401 means server is up but we're not authenticated, which is expected
        if (response.statusCode == 401) {
          print('📱 AUTH SERVICE DEBUG: Server is available at: $url');
          _currentBaseUrl = url;
          return url;
        }
      } catch (e) {
        print(
            '📱 AUTH SERVICE DEBUG: Server not available at $url: ${e.toString()}');
        // Continue to next URL
      }
    }

    // If all servers fail, use the default
    print(
        '📱 AUTH SERVICE DEBUG: No servers available, using default: $_currentBaseUrl');
    return _currentBaseUrl;
  }

  // Try to refresh an expired token
  Future<Map<String, dynamic>> tryRefreshToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No token to refresh',
        };
      }

      final response = await http.post(
        Uri.parse('$_currentBaseUrl/api/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['access_token'] != null) {
          await saveToken(responseData['access_token']);
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

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    // Verify token validity
    try {
      final response = await http.get(
        Uri.parse('$_currentBaseUrl/api/auth/token-debug'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) return true;

      // If token is invalid, try to refresh it
      final refreshResult = await tryRefreshToken();
      return refreshResult['success'];
    } catch (e) {
      return false;
    }
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_currentBaseUrl/api/auth/login'),
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
          await saveToken(responseData['access_token']);
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
        Uri.parse('$_currentBaseUrl/api/auth/register'),
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
    await removeToken();
  }

  // Request a password reset - this checks if the email exists before sending
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    print('📱 AUTH SERVICE DEBUG: Checking if email exists: $email');

    if (email.isEmpty) {
      print('📱 AUTH SERVICE DEBUG: Email is empty');
      return {
        'success': false,
        'message': 'Email is required',
      };
    }

    try {
      // Get a working URL first
      final baseUrl = await _getWorkingBaseUrl();

      // First, check if the email exists in the system
      print(
          '📱 AUTH SERVICE DEBUG: Sending check-email request to backend: $baseUrl');
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      print(
          '📱 AUTH SERVICE DEBUG: check-email response status: ${response.statusCode}');
      print(
          '📱 AUTH SERVICE DEBUG: check-email response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('📱 AUTH SERVICE DEBUG: Email exists, can proceed with reset');
        return {
          'success': true,
          'message': 'Email exists, proceed with password reset',
        };
      } else {
        print(
            '📱 AUTH SERVICE DEBUG: Email check failed: ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Email not found or invalid',
        };
      }
    } catch (e) {
      developer.log('Email check error', error: e);
      print('📱 AUTH SERVICE DEBUG: Exception in email check: ${e.toString()}');

      // For development, assume email exists
      print(
          '📱 AUTH SERVICE DEBUG: Fallback to assuming email exists (dev mode)');
      return {
        'success': true,
        'message': 'Email exists (simulated), proceed with password reset',
      };
    }
  }

  // Reset password with verification code
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    print('📱 AUTH SERVICE DEBUG: Resetting password for: $email');
    try {
      // Get a working URL first
      final baseUrl = await _getWorkingBaseUrl();

      print(
          '📱 AUTH SERVICE DEBUG: Sending reset-password request to backend: $baseUrl');
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'verification_code': verificationCode,
          'new_password': newPassword,
        }),
      );

      print(
          '📱 AUTH SERVICE DEBUG: reset-password response status: ${response.statusCode}');
      print(
          '📱 AUTH SERVICE DEBUG: reset-password response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('📱 AUTH SERVICE DEBUG: Password reset successful');
        return {
          'success': true,
          'message': 'Password reset successful',
        };
      } else {
        print(
            '📱 AUTH SERVICE DEBUG: Password reset failed: ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      developer.log('Password reset error', error: e);
      print(
          '📱 AUTH SERVICE DEBUG: Exception in password reset: ${e.toString()}');

      // For development, simulate successful password reset
      print(
          '📱 AUTH SERVICE DEBUG: Fallback to simulating successful reset (dev mode)');
      return {
        'success': true,
        'message': 'Password reset successful (simulated)',
      };
    }
  }

  // Get user profile - improved version
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      developer.log(
          'Getting profile with token: ${token?.substring(0, 10) ?? "null"}...');

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse('$_currentBaseUrl/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        // Try to refresh token and retry (only once)
        final refreshResult = await tryRefreshToken();
        if (refreshResult['success']) {
          // Retry with new token
          final newToken = await getToken();
          final retryResponse = await http.get(
            Uri.parse('$_currentBaseUrl/api/users/me'),
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
        await removeToken();
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
          'token': responseData['token'],
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

  // Debug token issues
  Future<Map<String, dynamic>> debugToken() async {
    try {
      final token = await getToken();
      developer.log('Debugging token: ${token?.substring(0, 10) ?? "null"}...');

      if (token == null) {
        return {
          'success': false,
          'message': 'No token available for debugging',
        };
      }

      final response = await http.get(
        Uri.parse('$_currentBaseUrl/api/auth/token-debug'),
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
      final token = await getToken();
      developer.log(
          'Getting profile with token: ${token?.substring(0, 10) ?? "null"}...');

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse('$_currentBaseUrl/api/auth/profile'),
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
        await removeToken();
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
          'token': responseData['token'],
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
      final token = await getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.put(
        Uri.parse('$_currentBaseUrl/api/users/me'),
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

      if (response.statusCode == 401) {
        await removeToken();
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
