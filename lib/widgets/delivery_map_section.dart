import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:winal_front_end/widgets/safe_google_map.dart';

// A helper widget to display a map with proper error handling
class DeliveryMapSection extends StatelessWidget {
  final bool showMap;
  final LatLng storeLocation;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;

  const DeliveryMapSection({
    Key? key,
    required this.showMap,
    required this.storeLocation,
    required this.markers,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showMap) {
      return const SizedBox.shrink(); // Return nothing if map should be hidden
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SafeGoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: storeLocation,
                zoom: 15,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
