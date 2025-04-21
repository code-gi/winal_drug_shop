import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  void _launchPhone(String phoneNumber) {
    _launchUrl('tel:$phoneNumber');
  }

  void _launchEmail(String email) {
    _launchUrl('mailto:$email');
  }

  void _launchMaps(String location) {
    _launchUrl('https://www.google.com/maps/search/?api=1&query=$location');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Winal Drug Shop',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'About Us'),
            Tab(icon: Icon(Icons.phone), text: 'Contact'),
            Tab(icon: Icon(Icons.description_outlined), text: 'Terms'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutTab(),
          _buildContactTab(),
          _buildTermsTab(),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/WELCOME-removebg-preview.png',
                height: 150,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Our Mission',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome to Winal Drug Shop, your trusted partner in veterinary and agricultural health solutions. '
                'We specialize in providing high-quality medications for animals, ensuring the well-being of pets, '
                'livestock, and farm animals.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Our Commitment',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Our commitment extends to supporting farm activities with essential products and guidance to boost productivity '
                'and animal health. In addition to our extensive veterinary offerings, we also supply a select range of human '
                'medications to cater to the basic health needs of our community.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Our Priority',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'At Winal Drug Shop, our priority is to deliver reliable, affordable, and effective health solutions '
                'with a focus on quality and customer satisfaction.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildFeaturesGrid(),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.pets,
        'title': 'Animal Care',
        'description': 'Quality medications for all animals',
      },
      {
        'icon': Icons.agriculture,
        'title': 'Farm Support',
        'description': 'Essential products for farm activities',
      },
      {
        'icon': Icons.medical_services,
        'title': 'Human Health',
        'description': 'Basic medications for human needs',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Expert Advice',
        'description': 'Professional guidance always available',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  features[index]['icon'],
                  size: 40,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 12),
                Text(
                  features[index]['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  features[index]['description'],
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'For inquiries, assistance, or feedback, feel free to reach out to us:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Contact card with animation
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildContactItem(
                      icon: Icons.phone,
                      title: 'Phone',
                      content: '+256 704550075',
                      onTap: () => _launchPhone('+256704550075'),
                    ),
                    const Divider(),
                    _buildContactItem(
                      icon: Icons.email,
                      title: 'Email',
                      content: 'winaldrugshop@gmail.com',
                      onTap: () => _launchEmail('winaldrugshop@gmail.com'),
                    ),
                    const Divider(),
                    _buildContactItem(
                      icon: Icons.location_on,
                      title: 'Location',
                      content: 'Nateete, Uganda',
                      onTap: () => _launchMaps('Nateete,Uganda'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Map placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('View on Google Maps'),
                onPressed: () => _launchMaps('Nateete,Uganda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Text(
            'Business Hours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),

          // Business hours table
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            children: const [
              TableRow(
                decoration: BoxDecoration(color: Colors.deepPurple),
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Hours',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Monday - Friday'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('8:00 AM - 6:00 PM'),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Saturday'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('9:00 AM - 5:00 PM'),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Sunday'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('10:00 AM - 2:00 PM'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Center(
            child: Text(
              'We are always ready to help with your medical needs and concerns.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Social media row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(FontAwesomeIcons.facebook, Colors.blue),
              const SizedBox(width: 16),
              _buildSocialButton(FontAwesomeIcons.twitter, Colors.lightBlue),
              const SizedBox(width: 16),
              _buildSocialButton(FontAwesomeIcons.instagram, Colors.purple),
              const SizedBox(width: 16),
              _buildSocialButton(FontAwesomeIcons.whatsapp, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade50,
              child: Icon(icon, color: Colors.deepPurple),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    String url = '';

    if (icon == FontAwesomeIcons.facebook) {
      url = 'https://www.facebook.com/winaldrugshop';
    } else if (icon == FontAwesomeIcons.twitter) {
      url = 'https://twitter.com/winaldrugshop';
    } else if (icon == FontAwesomeIcons.instagram) {
      url = 'https://www.instagram.com/winaldrugshop';
    } else if (icon == FontAwesomeIcons.whatsapp) {
      url = 'https://wa.me/256704550075';
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: color,
      child: IconButton(
        icon: FaIcon(icon, color: Colors.white, size: 20),
        onPressed: () => _launchUrl(url),
      ),
    );
  }

  Widget _buildTermsTab() {
    List<Map<String, dynamic>> termsAndConditions = [
      {
        'title': '1. General Information',
        'content':
            'Winal Drug Shop provides a wide range of medications and health-related products, primarily for animals, farm activities, and a select range of human medications. We are committed to providing high-quality, affordable, and reliable products and services to our customers.'
      },
      {
        'title': '2. Products and Services',
        'content': 'We offer the following categories of products and services:\n\n'
            '• Animal Medications: Including medications for pets, livestock, and farm animals.\n'
            '• Farm Activity Support: Products related to farming, including veterinary supplies and supplements.\n'
            '• Human Medications: A limited selection of basic medications for human health.\n\n'
            'All products available on our website and in-store are intended for specific uses as indicated by the manufacturer. It is important to consult with a medical professional or veterinarian before using any medication.'
      },
      {
        'title': '3. User Responsibilities',
        'content':
            'By using our services, you agree to: Provide accurate and complete information when purchasing products or interacting with our website...'
      },
      {
        'title': '4. Order Processing and Delivery',
        'content':
            'Orders are processed based on availability. While we strive to ensure all products are in stock, there may be cases where certain items are unavailable...'
      },
      {
        'title': '5. Pricing and Payment',
        'content':
            'Prices are listed in local currency and include applicable taxes unless stated otherwise. Winal Drug Shop accepts payment through various secure methods, including credit cards and online payment systems. We reserve the right to change product prices at any time without prior notice.'
      },
      {
        'title': '6. Returns and Refunds',
        'content':
            'Due to the nature of our products, we do not accept returns on opened medications or products unless they are defective or damaged upon receipt. If you receive a damaged or incorrect item, please contact us within 7 days of delivery for assistance with a return or exchange. Refunds will be processed according to our refund policy and applicable laws.'
      },
      {
        'title': '7. Privacy and Data Protection',
        'content':
            'We take your privacy seriously. By using our services, you agree to our Privacy Policy, which outlines how we collect, use, and protect your personal information. Your data will only be used to process your orders and provide customer support.'
      },
      {
        'title': '8. Health and Safety Disclaimer',
        'content':
            'All products sold by Winal Drug Shop are intended for use as directed by the manufacturer. For medications intended for animals, always consult a veterinarian before use. For human medications, please consult a healthcare professional. Winal Drug Shop is not liable for any adverse reactions, side effects, or misuse of products purchased through our store. In case of any doubts or concerns regarding a product\'s suitability or safety, please seek professional advice before use.'
      },
      {
        'title': '9. Limitation of Liability',
        'content':
            'To the fullest extent permitted by law, Winal Drug Shop shall not be liable for any indirect, incidental, or consequential damages arising from the use of our products or services. Our total liability shall not exceed the amount paid by the customer for the products in question.'
      },
      {
        'title': '10. Amendments to the Terms and Conditions',
        'content':
            'Winal Drug Shop reserves the right to modify or update these Terms and Conditions at any time. Any changes will be posted on our website, and the revised terms will be effective immediately upon posting. It is your responsibility to review these terms regularly.'
      },
      {
        'title': '11. Governing Law and Jurisdiction',
        'content':
            'These Terms and Conditions shall be governed by and construed in accordance with the laws of Uganda. Any disputes arising from the use of our services or products shall be subject to the jurisdiction of the courts in Uganda.'
      },
    ];

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: termsAndConditions.length + 1, // +1 for the header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Last Updated: March 27, 2025',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please read these terms and conditions carefully before using our services.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                const Divider(thickness: 1),
              ],
            );
          }

          final termIndex = index - 1;
          return ExpansionTile(
            title: Text(
              termsAndConditions[termIndex]['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  termsAndConditions[termIndex]['content'],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
