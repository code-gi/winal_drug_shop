import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SafeGoogleMap extends StatelessWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker>? markers;
  final void Function(GoogleMapController)? onMapCreated;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;

  const SafeGoogleMap({
    Key? key,
    required this.initialCameraPosition,
    this.markers,
    this.onMapCreated,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // Use a Future to simulate checking if maps are available
      future: Future.delayed(const Duration(milliseconds: 100), () => true),
      builder: (context, snapshot) {
        try {
          // Only render the map if we have a successful future result
          if (snapshot.hasData && snapshot.data == true) {
            return GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: initialCameraPosition,
              markers: markers ?? {},
              myLocationEnabled: myLocationEnabled,
              myLocationButtonEnabled: myLocationButtonEnabled,
            );
          }
        } catch (e) {
          // Log any exception that occurs
          print('Error building GoogleMap: $e');
        }

        // Show fallback UI for any error condition or while loading
        return _buildFallbackUI(context);
      },
    );
  }

  Widget _buildFallbackUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Map unavailable',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re having trouble loading the map',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
