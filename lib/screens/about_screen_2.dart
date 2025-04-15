import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animations/animations.dart';
import 'package:glassmorphism/glassmorphism.dart';

class EnhancedAboutUsScreen extends StatefulWidget {
  const EnhancedAboutUsScreen({Key? key}) : super(key: key);

  @override
  _EnhancedAboutUsScreenState createState() => _EnhancedAboutUsScreenState();
}

class _EnhancedAboutUsScreenState extends State<EnhancedAboutUsScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pageContents = [
    {
      'title': 'About Winal Drug Shop',
      'icon': Icons.info_outline,
      'backgroundColor': Colors.deepPurple,
      'content': _buildAboutContent(),
    },
    {
      'title': 'Our Services',
      'icon': Icons.medical_services,
      'backgroundColor': Colors.teal,
      'content': _buildServicesContent(),
    },
    {
      'title': 'Contact Us',
      'icon': Icons.contact_page,
      'backgroundColor': Colors.blue,
      'content': _buildContactContent(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pageContents[_currentPage]['backgroundColor'],
                  _pageContents[_currentPage]['backgroundColor']
                      .withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _pageContents[_currentPage]['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        _pageContents[_currentPage]['icon'],
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pageContents.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _pageContents[index]['content'],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation
                _buildBottomNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pageContents.length,
          (index) => GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Logo
        Center(
          child: Hero(
            tag: 'logo',
            child: Image.asset(
              'assets/images/WELCOME-removebg-preview.png',
              height: 200,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Mission Statement
        GlassmorphicContainer(
          width: double.infinity,
          height: 200,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFffffff).withOpacity(0.1),
              const Color(0xFFFFFFFF).withOpacity(0.05),
            ],
            stops: const [0.1, 1],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.5),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Our Mission',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Delivering high-quality veterinary and agricultural health solutions, ensuring the well-being of animals and supporting farm productivity.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Key Values Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final List<Map<String, dynamic>> values = [
              {
                'icon': Icons.medical_services,
                'title': 'Quality',
                'description': 'Premium health solutions',
              },
              {
                'icon': Icons.support_agent,
                'title': 'Support',
                'description': 'Expert guidance always',
              },
              {
                'icon': Icons.eco,
                'title': 'Sustainability',
                'description': 'Responsible healthcare',
              },
              {
                'icon': Icons.accessibility,
                'title': 'Accessibility',
                'description': 'Affordable care for all',
              },
            ];

            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    values[index]['icon'],
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    values[index]['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    values[index]['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  static Widget _buildServicesContent() {
    final List<Map<String, dynamic>> services = [
      {
        'icon': Icons.pets,
        'title': 'Veterinary Care',
        'description': 'Comprehensive medications for pets and livestock',
      },
      {
        'icon': Icons.agriculture,
        'title': 'Farm Support',
        'description': 'Essential products and supplements',
      },
      {
        'icon': Icons.medical_information,
        'title': 'Human Medications',
        'description': 'Basic health solutions',
      },
      {
        'icon': Icons.health_and_safety,
        'title': 'Consultation',
        'description': 'Professional health guidance',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our Services',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: ListTile(
                leading: Icon(
                  services[index]['icon'],
                  color: Colors.white,
                  size: 40,
                ),
                title: Text(
                  services[index]['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  services[index]['description'],
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static Widget _buildContactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Get in Touch',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Contact Information
        GlassmorphicContainer(
          width: double.infinity,
          height: 250,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFffffff).withOpacity(0.1),
              const Color(0xFFFFFFFF).withOpacity(0.05),
            ],
            stops: const [0.1, 1],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.5),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactRow(
                  icon: Icons.phone,
                  text: '+256 704550075',
                  onTap: () {}, // Implement phone launch
                ),
                const Divider(color: Colors.white30),
                _buildContactRow(
                  icon: Icons.email,
                  text: 'winaldrugshop@gmail.com',
                  onTap: () {}, // Implement email launch
                ),
                const Divider(color: Colors.white30),
                _buildContactRow(
                  icon: Icons.location_on,
                  text: 'Nateete, Uganda',
                  onTap: () {}, // Implement maps launch
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Social Media Links
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialIcon(FontAwesomeIcons.facebook),
            _buildSocialIcon(FontAwesomeIcons.twitter),
            _buildSocialIcon(FontAwesomeIcons.instagram),
            _buildSocialIcon(FontAwesomeIcons.whatsapp),
          ],
        ),
      ],
    );
  }

  static Widget _buildContactRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    );
  }

  static Widget _buildSocialIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: FaIcon(icon, color: Colors.white),
        onPressed: () {
          // Implement social media link logic
        },
      ),
    );
  }
}
