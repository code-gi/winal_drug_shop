import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class DistanceService {
  // Winal Drug Shop default location (Nateete, Kampala)
  static const LatLng defaultStoreLocation = LatLng(0.3025, 32.5539);

  // Base delivery fee in UGX;
  static const int baseDeliveryFee = 1000;

  // Fee per kilometer in UGX
  static const int feePerKilometer = 100;

  // Minimum delivery fee in UGX;
  static const int minimumDeliveryFee = 1000;

  // Maximum delivery fee in UGX - increase this for long distances
  static const int maximumDeliveryFee = 500000;

  // Google Maps API key
  static const String apiKey = 'AIzaSyDDOFf3CEvnjrcTpXIa2lLV6sRuV3GpUoI';

  // Calculate the delivery fee based on address string or coordinates
  static Future<int> calculateDeliveryFee({
    String? deliveryAddress,
    LatLng? deliveryLocation,
    LatLng? storeLocation,
  }) async {
    try {
      // If no delivery address or location is provided, return the minimum fee
      if ((deliveryAddress == null || deliveryAddress.isEmpty) &&
          deliveryLocation == null) {
        print(
            '📦 Using minimum delivery fee: $minimumDeliveryFee UGX (no location provided)');
        return minimumDeliveryFee;
      }

      // If we have coordinates, use them directly
      if (deliveryLocation != null) {
        return _calculateFeeFromCoordinates(
            deliveryLocation, storeLocation ?? defaultStoreLocation);
      }

      // Try to geocode the address
      try {
        // Get coordinates from address using Google Maps Geocoding API
        final coordinates = await getCoordinatesFromAddress(deliveryAddress!);

        if (coordinates != null) {
          // Calculate fee using the real coordinates
          final distanceInKm = await getDistanceFromCoordinates(
              storeLocation ?? defaultStoreLocation, coordinates);

          // Use the same progressive fee calculation
          int fee = baseDeliveryFee;

          if (distanceInKm <= 5) {
            fee = baseDeliveryFee;
          } else if (distanceInKm <= 20) {
            fee = baseDeliveryFee +
                ((distanceInKm - 5) * feePerKilometer).round();
          } else if (distanceInKm <= 100) {
            fee = baseDeliveryFee + 1500 + ((distanceInKm - 20) * 80).round();
          } else {
            fee = baseDeliveryFee + 7900 + ((distanceInKm - 100) * 50).round();
          }

          // Ensure fee is within the allowed range
          final int finalFee =
              min(maximumDeliveryFee, max(minimumDeliveryFee, fee));

          print(
              '📦 Calculated delivery fee: $finalFee UGX for address: $deliveryAddress');
          print('📏 Real distance: ${distanceInKm.toStringAsFixed(2)} km');
          print('📊 Fee calculation breakdown:');
          print('  - Base fee: $baseDeliveryFee UGX');
          print('  - Distance fee: ${fee - baseDeliveryFee} UGX');

          return finalFee;
        } else {
          // Fallback to basic calculation if geocoding fails
          print('⚠️ Geocoding failed, using basic distance calculation');
          final double estimatedDistance = 5.0; // Default value
          final int fee =
              baseDeliveryFee + (feePerKilometer * estimatedDistance).round();
          return min(maximumDeliveryFee, max(minimumDeliveryFee, fee));
        }
      } catch (e) {
        print('❌ Error calculating fee from address: $e');
        return minimumDeliveryFee;
      }
    } catch (e) {
      print('❌ Error in calculateDeliveryFee: $e');
      return minimumDeliveryFee;
    }
  }

  // Calculate fee based on coordinates
  static Future<int> _calculateFeeFromCoordinates(
      LatLng deliveryLocation, LatLng storeLocation) async {
    try {
      // Get real distance using Google Maps Distance Matrix API
      final double distanceInKm =
          await getDistanceFromCoordinates(storeLocation, deliveryLocation);

      // Calculate fee based on distance with a progressive rate
      int fee = baseDeliveryFee;

      // Progressive rate calculation:
      // First 5 km: base fee only
      // 5-20 km: base fee + 100 UGX per km
      // 20-100 km: base fee + 2000 + 80 UGX per km beyond 20km
      // Above 100 km: base fee + 8400 + 50 UGX per km beyond 100km

      if (distanceInKm <= 5) {
        // Only base fee for short distances
        fee = baseDeliveryFee;
      } else if (distanceInKm <= 20) {
        // Standard rate for medium distances
        fee = baseDeliveryFee + ((distanceInKm - 5) * feePerKilometer).round();
      } else if (distanceInKm <= 100) {
        // Reduced rate for longer distances
        fee = baseDeliveryFee + 1500 + ((distanceInKm - 20) * 80).round();
      } else {
        // Further reduced rate for very long distances
        fee = baseDeliveryFee + 7900 + ((distanceInKm - 100) * 50).round();
      }

      // Ensure fee is within the allowed range, but with higher maximum
      final int finalFee =
          min(maximumDeliveryFee, max(minimumDeliveryFee, fee));

      print('📦 Calculated delivery fee: $finalFee UGX');
      print('📏 Real distance: ${distanceInKm.toStringAsFixed(2)} km');
      print('📊 Fee calculation breakdown:');
      print('  - Base fee: $baseDeliveryFee UGX');
      print('  - Distance fee: ${fee - baseDeliveryFee} UGX');
      print('  - Total before capping: $fee UGX');
      if (fee != finalFee) {
        print('  - Fee capped to maximum: $finalFee UGX');
      }

      return finalFee;
    } catch (e) {
      print('❌ Error calculating fee from coordinates: $e');
      return minimumDeliveryFee;
    }
  }

  // Method to get coordinates from an address using Google Maps Geocoding API
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      // Encode address for URL
      final encodedAddress = Uri.encodeComponent(address);

      // Create API request URL with region biasing for Uganda
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey&region=ug';

      // Make HTTP request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];

          // Print formatted address to debug
          print(
              '📍 Geocoded address: ${data['results'][0]['formatted_address']}');

          return LatLng(location['lat'], location['lng']);
        } else {
          print('⚠️ Geocoding API error: ${data['status']}');

          // If the location wasn't found, try adding "Uganda" to the query
          if (!address.toLowerCase().contains('uganda')) {
            print('🔍 Retrying with country name added...');
            return getCoordinatesFromAddress('$address, Uganda');
          }
          return null;
        }
      } else {
        print('⚠️ Geocoding API HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error in getCoordinatesFromAddress: $e');
      return null;
    }
  }

  // Method to get distance between two coordinates using Google Maps Distance Matrix API
  static Future<double> getDistanceFromCoordinates(
      LatLng origin, LatLng destination) async {
    try {
      // Create origin and destination strings
      final originStr = '${origin.latitude},${origin.longitude}';
      final destinationStr = '${destination.latitude},${destination.longitude}';

      // Create API request URL
      final url =
          'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$originStr&destinations=$destinationStr&key=$apiKey';

      // Make HTTP request with timeout
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        print('⚠️ Distance Matrix API request timed out');
        throw TimeoutException('Distance Matrix API request timed out');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' &&
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'].isNotEmpty &&
            data['rows'][0]['elements'][0]['status'] == 'OK') {
          // Get distance in meters and convert to kilometers
          final distanceInMeters =
              data['rows'][0]['elements'][0]['distance']['value'];

          final distance = distanceInMeters / 1000.0;
          print(
              '📏 Distance Matrix API calculated distance: ${distance.toStringAsFixed(2)} km');
          return distance;
        } else {
          print('⚠️ Distance Matrix API error: ${data['status']}');
          // Log more details about the error
          if (data['rows'].isNotEmpty &&
              data['rows'][0]['elements'].isNotEmpty) {
            print(
                '⚠️ Element status: ${data['rows'][0]['elements'][0]['status']}');
          }

          // Fallback to Haversine formula calculation
          final haversineDistance =
              calculateHaversineDistance(origin, destination);
          print(
              '📏 Falling back to Haversine distance: ${haversineDistance.toStringAsFixed(2)} km');
          return haversineDistance;
        }
      } else {
        print('⚠️ Distance Matrix API HTTP error: ${response.statusCode}');
        // Fallback to Haversine formula calculation
        final haversineDistance =
            calculateHaversineDistance(origin, destination);
        print(
            '📏 Falling back to Haversine distance: ${haversineDistance.toStringAsFixed(2)} km');
        return haversineDistance;
      }
    } catch (e) {
      print('❌ Error in getDistanceFromCoordinates: $e');

      // Check for common network errors
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        print('⚠️ Network error: ${e.toString()}');
      }

      // Fallback to Haversine formula calculation
      final haversineDistance = calculateHaversineDistance(origin, destination);
      print(
          '📏 Falling back to Haversine distance after error: ${haversineDistance.toStringAsFixed(2)} km');
      return haversineDistance;
    }
  }

  // Calculate distance between two points using the Haversine formula (as fallback)
  static double calculateHaversineDistance(LatLng start, LatLng end) {
    try {
      // Using the Geolocator package's distanceBetween method for this calculation
      final distanceInMeters = Geolocator.distanceBetween(
          start.latitude, start.longitude, end.latitude, end.longitude);

      print('🔢 Haversine distance calculation successful');
      return distanceInMeters / 1000.0; // Convert to kilometers
    } catch (e) {
      print('❌ Error in Haversine calculation: $e');

      // If Geolocator fails too, implement a very basic estimate based on coordinates
      // This is a simplified version - not accurate for long distances but better than nothing
      final lat1 = start.latitude;
      final lon1 = start.longitude;
      final lat2 = end.latitude;
      final lon2 = end.longitude;

      // Rough distance based on Pythagorean theorem
      // (sufficient as a last-resort backup)
      const double equatorialCircumference =
          40075.0; // Earth circumference at equator in km
      const double kmPerLatDegree = equatorialCircumference / 360.0;

      final latDistance = (lat2 - lat1).abs() * kmPerLatDegree;
      final lonDistance = (lon2 - lon1).abs() *
          kmPerLatDegree *
          cos((lat1 + lat2) * pi / 360.0);

      final roughDistance =
          sqrt(latDistance * latDistance + lonDistance * lonDistance);
      print(
          '⚠️ Using very rough distance estimate: ${roughDistance.toStringAsFixed(2)} km');

      return roughDistance;
    }
  }

  // Add more locations to the known distances map
  static final Map<String, double> knownDistancesFromNateete = {
    'kampala': 3.5,
    'entebbe': 35.0,
    'jinja': 80.0,
    'mbarara': 260.0,
    'gulu': 330.0,
    'mbale': 224.0,
    'fort portal': 294.0,
    'arua': 455.0,
    'kabale': 420.0,
    'masaka': 135.0,
    'tororo': 205.0,
    'hoima': 200.0,
    'lira': 334.0,
    'soroti': 305.0,
    'kasese': 365.0,
    'kyengera': 10.0,
    'nsangi': 15.0,
    'wakiso': 20.0,
    'mukono': 25.0,
    'busega': 5.0,
    'lubowa': 15.0,
    'gayaza': 20.0,
    'kawempe': 7.0,
    'ntinda': 12.0,
    'naguru': 10.0,
    'bweyogerere': 18.0,
    'kireka': 13.0,
    'nalumunye': 12.0,
    'kajjansi': 22.0,
    'matugga': 25.0,
    'nansana': 8.0,
    'namulanda': 30.0,
    'kisubi': 32.0,
    'makindye': 8.0,
    'kabalagala': 9.0,
    'buziga': 12.0,
    'munyonyo': 14.0,
    'nakawa': 9.0,
    'bugolobi': 10.0,
    'kikoni': 6.0,
    'makerere': 4.0,
    'bukoto': 7.0,
    'nansana': 8.0,
    'mengo': 2.0,
    'kalerwe': 6.0,
    // Add more smaller locations and neighborhoods
  };

  // Enhanced method to check for known locations
  static double getKnownDistance(String address) {
    final lowerAddress = address.toLowerCase();

    // Check for exact matches first
    for (final entry in knownDistancesFromNateete.entries) {
      if (lowerAddress == entry.key ||
          lowerAddress.contains(' ${entry.key} ') ||
          lowerAddress.contains('${entry.key}, ') ||
          lowerAddress.contains(', ${entry.key}')) {
        print(
            '📍 Found exact match for location "${entry.key}" with distance: ${entry.value} km');
        return entry.value;
      }
    }

    // Check for partial matches
    for (final entry in knownDistancesFromNateete.entries) {
      if (lowerAddress.contains(entry.key)) {
        print(
            '📍 Found location "${entry.key}" with distance: ${entry.value} km');
        return entry.value;
      }
    }

    // If no known city is found, return a default value
    return 5.0;
  }
}

// Extra exception classes to handle network issues
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
