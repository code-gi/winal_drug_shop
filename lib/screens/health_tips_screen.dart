import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({Key? key}) : super(key: key);

  @override
  _HealthTipsScreenState createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  final List<Map<String, dynamic>> healthTips = [
    {
      'image': 'assets/images/WATER.jpeg',
      'title': 'Drink plenty of water daily',
      'description':
          'Drink plenty of water daily to keep your skin glowing and your body energized during festive celebrations.',
      'tip':
          '💧 Tip: Pair with our hydrating skincare products for radiant skin!',
    },
    {
      'image': 'assets/images/DIET.jpeg',
      'title': 'Eat a balanced diet',
      'description':
          'Include fruits, vegetables, and lean proteins in your meals to stay healthy and energetic.',
      'tip': null,
    },
    {
      'image': 'assets/images/WALK.jpeg',
      'title': 'Stay Active',
      'description':
          'Take walks or participate in family activities to stay fit while enjoying the season.',
      'tip': '🏃‍♂️ Tip: Support your joints with our wellness supplements.',
    },
    {
      'image': 'assets/images/IMMUNITY.jpeg',
      'title': 'Boost your immunity',
      'description':
          'Stock up on vitamin C and zinc to boost your immunity and stay healthy.',
      'tip': 'Tip: Explore your immune boosting supplements.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 222, 226),
      appBar: AppBar(
        title: const Text('Health Tips'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Health Tips',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 236, 232, 232),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CarouselSlider.builder(
                itemCount: healthTips.length,
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child: Image.asset(
                            healthTips[index]['image'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                healthTips[index]['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                healthTips[index]['description'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (healthTips[index]['tip'] != null)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    healthTips[index]['tip'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 400,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
