import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // User authentication state
  bool _isAuthenticated = false;
  String? _errorMessage;
  Map<String, dynamic>? _fieldErrors;
  Map<String, dynamic>? _userData;
  String? _token;
  bool _isLoading = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get fieldErrors => _fieldErrors;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;
  bool get isLoading => _isLoading;

  // Check if a specific field has errors
  bool hasFieldError(String fieldName) {
    return _fieldErrors?.containsKey(fieldName) ?? false;
  }

  // Get error message for a specific field
  String? getFieldError(String fieldName) {
    final errors = getFieldErrors(fieldName);
    return errors.isNotEmpty ? errors.join('\n') : null;
  }

  // Get all error messages for a specific field
  List<String> getFieldErrors(String fieldName) {
    if (_fieldErrors == null || !_fieldErrors!.containsKey(fieldName)) {
      return [];
    }

    final fieldError = _fieldErrors![fieldName];
    if (fieldError is Map<String, dynamic> &&
        fieldError.containsKey('errors')) {
      final errors = fieldError['errors'] as List<dynamic>;
      return errors.map((error) => error.toString()).toList();
    }

    return [fieldError.toString()];
  }

  // Get requirement message for a specific field
  String? getFieldRequirement(String fieldName) {
    if (_fieldErrors == null || !_fieldErrors!.containsKey(fieldName)) {
      return null;
    }

    final fieldError = _fieldErrors![fieldName];
    if (fieldError is Map<String, dynamic> &&
        fieldError.containsKey('requirement')) {
      final requirement = fieldError['requirement'].toString();
      final errors = getFieldErrors(fieldName);
      if (fieldName == 'password' || errors.contains(requirement)) {
        return null;
      }
      return requirement;
    }

    return null;
  }

  // Constructor - check if user is already logged in
  AuthProvider() {
    _checkLoginStatus();
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    _isAuthenticated = await _authService.isLoggedIn();

    if (_isAuthenticated) {
      // Get user profile
      await getUserProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _fieldErrors = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success']) {
      _isAuthenticated = true;
      _userData = result['data'];
      _token = result['token'];
    } else {
      _errorMessage = result['message'];
      if (result.containsKey('field_errors')) {
        _fieldErrors = result['field_errors'];
      }
    }

    _isLoading = false;
    notifyListeners();
    return result['success'];
  }

  // Register method
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String dateOfBirth,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _fieldErrors = null;
    notifyListeners();

    final result = await _authService.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
    );

    _isLoading = false;

    if (!result['success']) {
      _errorMessage = result['message'];
      if (result.containsKey('field_errors')) {
        _fieldErrors = result['field_errors'];
      }
    }

    notifyListeners();
    return result['success'];
  }

  // Logout method
  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _userData = null;
    _fieldErrors = null;
    notifyListeners();
  }

  // Get user profile
  Future<void> getUserProfile() async {
    if (!_isAuthenticated) return;

    final result = await _authService.getUserProfile();

    if (result['success']) {
      _userData = result['data'];
      _token = result['token'];
    } else {
      // If getting profile fails, user might be logged out
      if (result['message'] == 'Not authenticated') {
        _isAuthenticated = false;
      }
    }

    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    if (!_isAuthenticated) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );

    _isLoading = false;

    if (result['success']) {
      // Update the local user data with the new values
      _userData?['first_name'] = firstName;
      _userData?['last_name'] = lastName;
      _userData?['phone_number'] = phoneNumber;
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result['success'];
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    _fieldErrors = null;
    notifyListeners();
  }
}
