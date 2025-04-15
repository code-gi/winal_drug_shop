import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmActivityService {
  // Base URL for the Flask backend API - now hosted on Render.com
  final String baseUrl = 'https://winal-backend.onrender.com';

  // Alternative server URLs to try if the primary one fails
  final List<String> fallbackUrls = [
    'https://winal-backend.onrender.com', // Primary cloud-hosted URL
    'http://192.168.43.57:5000', // Legacy mobile hotspot (backup)
    'http://localhost:5000', // Local development
    'http://10.0.2.2:5000' // Android emulator to host loopback
  ];

  // Method to fetch farm activities from the backend
  Future<List<dynamic>> fetchFarmActivities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/farm-activities'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load farm activities');
      }
    } catch (e) {
      print('Error fetching farm activities: $e');
      return [];
    }
  }

  // Method to save farm activity locally using SharedPreferences
  Future<void> saveFarmActivityLocally(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, jsonEncode(value));
  }

  // Method to retrieve farm activity locally using SharedPreferences
  Future<dynamic> getFarmActivityLocally(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    return value != null ? jsonDecode(value) : null;
  }
}
