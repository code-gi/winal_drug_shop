import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({Key? key}) : super(key: key);

  @override
  _HealthTipsScreenState createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCarouselIndex = 0;
  Set<String> _bookmarkedTips = {};
  bool _isLoading = true;

  // Human health tips
  final List<Map<String, dynamic>> _humanHealthTips = [
    {
      'id': 'h1',
      'image': 'assets/images/WATER.jpeg',
      'title': 'Drink plenty of water daily',
      'description':
          'Drink plenty of water daily to keep your skin glowing and your body energized during festive celebrations.',
      'tip':
          '💧 Tip: Pair with our hydrating skincare products for radiant skin!',
    },
    {
      'id': 'h2',
      'image': 'assets/images/DIET.jpeg',
      'title': 'Eat a balanced diet',
      'description':
          'Include fruits, vegetables, and lean proteins in your meals to stay healthy and energetic.',
      'tip':
          '🥗 Tip: Try to include at least 5 servings of vegetables and fruits daily.',
    },
    {
      'id': 'h3',
      'image': 'assets/images/WALK.jpeg',
      'title': 'Stay Active',
      'description':
          'Take walks or participate in family activities to stay fit while enjoying the season.',
      'tip': '🏃‍♂️ Tip: Support your joints with our wellness supplements.',
    },
    {
      'id': 'h4',
      'image': 'assets/images/IMMUNITY.jpeg',
      'title': 'Boost your immunity',
      'description':
          'Stock up on vitamin C and zinc to boost your immunity and stay healthy.',
      'tip': '🍊 Tip: Explore our immune boosting supplements.',
    },
  ];

  // Animal health tips
  final List<Map<String, dynamic>> _animalHealthTips = [
    {
      'id': 'a1',
      'image': 'assets/images/DOG.jpeg',
      'title': 'Regular Vet Check-ups',
      'description':
          'Schedule regular check-ups for your pets, even when they seem healthy, to catch potential issues early.',
      'tip':
          '🐾 Tip: Ask about our animal health plans for regular preventative care.',
    },
    {
      'id': 'a2',
      'image': 'assets/images/CAT.jpeg',
      'title': 'Keep Pets Hydrated',
      'description':
          'Ensure your pets have access to fresh water at all times, especially during hot weather.',
      'tip': '💦 Tip: Consider a pet water fountain to encourage drinking.',
    },
    {
      'id': 'a3',
      'image': 'assets/images/DEWORMER.jpg',
      'title': 'Regular Deworming',
      'description':
          'Maintain a regular deworming schedule for all your animals to prevent parasite infestations.',
      'tip':
          '🦠 Tip: We offer a range of safe deworming products for all types of animals.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookmarkedTips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarkedTips() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedTips =
          Set<String>.from(prefs.getStringList('bookmarkedTips') ?? []);
      _isLoading = false;
    });
  }

  Future<void> _toggleBookmark(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedTips.contains(tipId)) {
        _bookmarkedTips.remove(tipId);
      } else {
        _bookmarkedTips.add(tipId);
      }
    });
    await prefs.setStringList('bookmarkedTips', _bookmarkedTips.toList());
  }

  List<Map<String, dynamic>> get _bookmarkedTipsList {
    List<Map<String, dynamic>> result = [];
    for (var tip in _humanHealthTips) {
      if (_bookmarkedTips.contains(tip['id'])) {
        result.add(tip);
      }
    }
    for (var tip in _animalHealthTips) {
      if (_bookmarkedTips.contains(tip['id'])) {
        result.add(tip);
      }
    }
    return result;
  }

  void _shareTip(Map<String, dynamic> tip) {
    Share.share(
      '${tip['title']}\n\n${tip['description']}\n\n${tip['tip'] ?? ''}\n\nShared from Winal Drug Shop App',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Health Tips', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Human', icon: Icon(Icons.person)),
            Tab(text: 'Animal', icon: Icon(Icons.pets)),
            Tab(text: 'Bookmarks', icon: Icon(Icons.bookmark)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTipsCarousel(_humanHealthTips),
                _buildTipsCarousel(_animalHealthTips),
                _buildBookmarkedTips(),
              ],
            ),
    );
  }

  Widget _buildTipsCarousel(List<Map<String, dynamic>> tips) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: CarouselSlider.builder(
            itemCount: tips.length,
            itemBuilder: (context, index, realIndex) {
              return _buildTipCard(tips[index]);
            },
            options: CarouselOptions(
              height: double.infinity,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 7),
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              aspectRatio: 16 / 9,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: tips.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == entry.key
                    ? Colors.blue
                    : Colors.grey.shade400,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    bool isBookmarked = _bookmarkedTips.contains(tip['id']);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  tip['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      child: IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Colors.blue : Colors.black,
                        ),
                        onPressed: () => _toggleBookmark(tip['id']),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.black),
                        onPressed: () => _shareTip(tip),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['description'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (tip['tip'] != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline,
                                      color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tip['tip'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/medications');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Browse Related Products'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkedTips() {
    if (_bookmarkedTipsList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookmarked tips yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Bookmark tips you find useful to access them later',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarkedTipsList.length,
      itemBuilder: (context, index) {
        final tip = _bookmarkedTipsList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _buildTipDetailBottomSheet(tip),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      tip['image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: Colors.blue),
                    onPressed: () => _toggleBookmark(tip['id']),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipDetailBottomSheet(Map<String, dynamic> tip) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    tip['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.7),
                          child: IconButton(
                            icon: const Icon(Icons.share, color: Colors.black),
                            onPressed: () {
                              _shareTip(tip);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tip['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (tip['tip'] != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                color: Colors.amber, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip['tip'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/medications');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Browse Related Products',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
