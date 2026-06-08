import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;

class DeliveryMapScreen extends StatefulWidget {
  final String pickupAddress;
  final String deliveryAddress;
  final LatLng? pickupLocation;
  final LatLng? deliveryLocation;

  const DeliveryMapScreen({
    Key? key,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.pickupLocation,
    this.deliveryLocation,
  }) : super(key: key);

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  bool _useSimpleMap = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    // Simple delay to simulate loading
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        // Always use simple map on web to avoid JavaScript errors
        _useSimpleMap = kIsWeb ? true : _useSimpleMap;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Delivery Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Only show toggle button on native platforms
          if (!kIsWeb)
            IconButton(
              icon: Icon(
                _useSimpleMap ? Icons.map_outlined : Icons.view_list_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _useSimpleMap = !_useSimpleMap;
                });
              },
              tooltip: _useSimpleMap
                  ? 'Switch to Google Maps'
                  : 'Switch to Simple View',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Delivery information card
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                            Icons.location_on, 'From', widget.pickupAddress),
                        const Divider(),
                        _buildInfoRow(
                            Icons.where_to_vote, 'To', widget.deliveryAddress),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.route,
                          'Estimated Distance',
                          _calculateDistanceString(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Map section (takes remaining space)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: kIsWeb || _useSimpleMap
                        ? _buildSimpleMap()
                        : _buildGoogleMap(),
                  ),
                ),
              ],
            ),
    );
  }

  String _calculateDistanceString() {
    double distance = 5.7; // Default distance

    // If we have both locations, calculate actual distance
    if (widget.pickupLocation != null && widget.deliveryLocation != null) {
      distance = _calculateDistance(
          widget.pickupLocation!.latitude,
          widget.pickupLocation!.longitude,
          widget.deliveryLocation!.latitude,
          widget.deliveryLocation!.longitude);
    }

    return '${distance.toStringAsFixed(1)} km (approximate)';
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // This is a simplified distance calculation (Haversine formula)
    const double earthRadius = 6371; // Radius of the earth in km

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c; // Distance in km

    return double.parse(distance.toStringAsFixed(1));
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  double sin(double x) {
    return math.sin(x);
  }

  double cos(double x) {
    return math.cos(x);
  }

  double atan2(double y, double x) {
    return math.atan2(y, x);
  }

  double sqrt(double x) {
    return math.sqrt(x);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMap() {
    return Stack(
      children: [
        Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Delivery Route',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      const Text('Pickup'),
                      const SizedBox(width: 20),
                      Container(width: 50, height: 2, color: Colors.grey[400]),
                      const SizedBox(width: 20),
                      Icon(Icons.location_on,
                          color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      const Text('Delivery'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'From: ${widget.pickupAddress}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'To: ${widget.deliveryAddress}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Message at bottom
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                'Using simplified map for compatibility',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleMap() {
    try {
      return FutureBuilder<bool>(
        future: Future.delayed(const Duration(milliseconds: 300), () => true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.pickupLocation ?? const LatLng(0.3025, 32.5539),
                zoom: 14,
              ),
              markers: _createMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              onMapCreated: (controller) {
                // Controller can be saved if needed
              },
            );
          } catch (e) {
            print('Google Maps error: $e');

            // Switch to simple map on error
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _useSimpleMap = true;
                });
              }
            });

            return _buildErrorView();
          }
        },
      );
    } catch (e) {
      print('Failed to build Google Maps: $e');
      return _buildErrorView();
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Google Maps unavailable',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'There was an issue loading the Google Maps component.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _useSimpleMap = true;
              });
            },
            child: const Text('Switch to Simple Map'),
          ),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};

    // Add pickup marker
    if (widget.pickupLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: widget.pickupLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow:
              InfoWindow(title: 'Pickup', snippet: widget.pickupAddress),
        ),
      );
    }

    // Add delivery marker
    if (widget.deliveryLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: widget.deliveryLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow:
              InfoWindow(title: 'Delivery', snippet: widget.deliveryAddress),
        ),
      );
    } else {
      // Add a default delivery marker if location is not provided
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: const LatLng(
              0.3125, 32.5639), // Slightly offset from default pickup
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow:
              InfoWindow(title: 'Delivery', snippet: widget.deliveryAddress),
        ),
      );
    }

    return markers;
  }
}
