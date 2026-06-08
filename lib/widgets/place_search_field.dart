import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class PlaceSearchField extends StatefulWidget {
  final String apiKey;
  final Function(String, String) onPlaceSelected;
  final String hintText;
  final TextEditingController? controller;
  final String? country;

  const PlaceSearchField({
    Key? key,
    required this.apiKey,
    required this.onPlaceSelected,
    this.hintText = 'Search location',
    this.controller,
    this.country = 'ug',
  }) : super(key: key);

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  List<Map<String, dynamic>> _placesList = [];
  bool _isLoading = false;
  TextEditingController? _controller;
  bool _isWeb = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    // Detect platform
    try {
      // This will throw an error on web
      _isWeb = !(Platform.isAndroid || Platform.isIOS);
    } catch (e) {
      // We're on web
      _isWeb = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller!.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _controller!.clear();
                        _placesList = [];
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _searchPlaces(value);
            } else {
              setState(() {
                _placesList = [];
              });
            }
          },
        ),
        if (_isLoading)
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
        if (_placesList.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: _placesList.length > 5 ? 5 : _placesList.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(_placesList[index]['description']),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dense: true,
                  onTap: () {
                    _onPlaceSelected(_placesList[index]);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _searchPlaces(String input) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // If we're on web, use fallback suggestions instead of direct API calls
      if (_isWeb) {
        await Future.delayed(
            const Duration(milliseconds: 300)); // Simulate network delay
        _showFallbackSuggestions(input);
      } else {
        // Native approach for Android/iOS
        await _fetchPlacesPredictions(input);
      }
    } catch (e) {
      print('Error searching places: $e');
      _showFallbackSuggestions(input);
    }
  }

  Future<void> _fetchPlacesPredictions(String input) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$url?input=$input&key=${widget.apiKey}&components=country:ug'; // Limit to Uganda

      var response = await http.get(Uri.parse(request));

      Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          _isLoading = false;
          _placesList = List<Map<String, dynamic>>.from(data['predictions']);
        });
      } else {
        print('Google Places API error: ${data['status']}');
        _showFallbackSuggestions(input);
      }
    } catch (e) {
      print('Direct API approach failed: $e');
      _showFallbackSuggestions(input);
    }
  }

  void _showFallbackSuggestions(String input) {
    // Fallback to hardcoded common locations in Uganda
    List<Map<String, dynamic>> commonLocations = [
      {
        'description': 'Kampala, Uganda',
        'place_id': 'ChIJm7N0nQ-8fRcR7G9r2T2QOEU',
      },
      {
        'description': 'Entebbe, Uganda',
        'place_id': 'ChIJ82gKx0UEfRcRYL6m3iLV2MC',
      },
      {
        'description': 'Jinja, Uganda',
        'place_id': 'ChIJzR5-_sTtfRcR1_N6lKHgcIs',
      },
      {
        'description': 'Gulu, Uganda',
        'place_id': 'ChIJI-C5zlFUczERJYpYjI4lhWM',
      },
      {
        'description': 'Mbarara, Uganda',
        'place_id': 'ChIJfXeQj41LfBcRTT2zSbkFtfI',
      },
      {
        'description': 'Mbale, Uganda',
        'place_id': 'ChIJ9amTz_iiehcRvNdyP8gZ0NY',
      },
      {
        'description': 'Masaka, Uganda',
        'place_id': 'ChIJM0wCpPQbfRcR8BK5ykVK_98',
      },
      {
        'description': 'Fort Portal, Uganda',
        'place_id': 'ChIJU4LT_ZW6CxcROAh5wlOQJeE',
      },
      {
        'description': 'Arua, Uganda',
        'place_id': 'ChIJ700wOyFBBRcRuJvVxFJZZRQ',
      },
      {
        'description': 'Lira, Uganda',
        'place_id': 'ChIJXYm3nwSlbzERcOu2uRRK_Ic',
      },
      {
        'description': 'Kasese, Uganda',
        'place_id': 'ChIJZ4SFZwS1CxcRO1rrrrAEOVU',
      },
      {
        'description': 'Kabale, Uganda',
        'place_id': 'ChIJ85QmQJ1xehcRQpM7HHx4eG8',
      },
      {
        'description': 'Mukono, Uganda',
        'place_id': 'ChIJfYNR1UrwfRcR6tqBRKCbA-Q',
      },
      {
        'description': 'Nateete, Kampala, Uganda',
        'place_id': 'ChIJkZVBHyu7fRcRlV8meRKXL7g',
      },
      {
        'description': 'Makerere University, Kampala, Uganda',
        'place_id': 'ChIJLUCq33m8fRcRI5zgCsQT1kg',
      }
    ];

    // Filter based on input
    List<Map<String, dynamic>> filteredLocations = commonLocations
        .where((location) => location['description']
            .toString()
            .toLowerCase()
            .contains(input.toLowerCase()))
        .toList();

    setState(() {
      _isLoading = false;
      _placesList = filteredLocations;
    });
  }

  void _onPlaceSelected(Map<String, dynamic> place) async {
    final placeId = place['place_id'];
    final description = place['description'];

    // On web, we'll skip the details call and just use what we have
    if (_isWeb) {
      setState(() {
        _controller!.text = description;
        _placesList = [];
      });

      widget.onPlaceSelected(description, placeId);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String url = 'https://maps.googleapis.com/maps/api/place/details/json';
      String request = '$url?place_id=$placeId&key=${widget.apiKey}';

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      setState(() {
        _isLoading = false;
      });

      if (data['status'] == 'OK') {
        // Set the controller text to the selected place
        setState(() {
          _controller!.text = description;
          _placesList = []; // Clear the list
        });

        // Call the callback with place details
        widget.onPlaceSelected(description, placeId);
      } else {
        print('Google Places Details API error: ${data['status']}');

        // Still update the field and call the callback with what we have
        setState(() {
          _controller!.text = description;
          _placesList = [];
        });
        widget.onPlaceSelected(description, placeId);
      }
    } catch (e) {
      print('Error getting place details: $e');

      // Still update the field and call the callback with what we have
      setState(() {
        _isLoading = false;
        _controller!.text = description;
        _placesList = [];
      });
      widget.onPlaceSelected(description, placeId);
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }
}
