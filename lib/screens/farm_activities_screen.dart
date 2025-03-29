import 'package:flutter/material.dart';
import 'medications_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FarmActivitiesScreen(),
    );
  }
}

class FarmActivitiesScreen extends StatelessWidget {
  // List of activities with their labels and placeholder image paths
  final List<Map<String, String>> activities = [
    {'label': 'Farm visits', 'image': 'assets/images/FARM VISITS.jpeg'},
    {'label': 'Seminars', 'image': 'assets/images/SEMINARS.jpeg'},
    {'label': 'Retreats', 'image': 'assets/images/RETREATS.jpeg'},
    {'label': 'Mentorship', 'image': 'assets/images/MENTORSHIP.jpeg'},
    {'label': 'Construction', 'image': 'assets/images/CONSTRUCTION.jpeg'},
    {'label': 'Financial services', 'image': 'assets/images/FINANCIAL.jpeg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Farm Activities'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced overall padding
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 8.0, // Reduced spacing between columns
            mainAxisSpacing: 8.0, // Reduced spacing between rows
            childAspectRatio: 0.75, // Adjusted aspect ratio to fit rectangular cards better
          ),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            return ActivityCard(
              label: activities[index]['label']!,
              imagePath: activities[index]['image']!,
            );
          },
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String label;
  final String imagePath;

  const ActivityCard({required this.label, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rectangular image container with rounded corners
        Container(
          width: double.infinity, // Take full width of the grid cell
          height: 120, // Fixed height for the image
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            image: DecorationImage(
              image: AssetImage(imagePath), // Use the image path
              fit: BoxFit.cover, // Ensure the image covers the container
            ),
          ),
        ),
        const SizedBox(height: 4.0), // Reduced space between image and label
        // Label text
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}