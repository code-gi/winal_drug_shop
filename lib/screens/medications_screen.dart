import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Assuming these screens are defined elsewhere in your project
import 'animal_medications.dart'; // Replace with actual import if different
import 'human_medications.dart';   // Replace with actual import if different
import 'sign_up_screen.dart';      // Replace with actual import if different
import 'call_screen.dart';         // Replace with actual import if different
import 'chat_screen.dart';         // Replace with actual import if different
import 'notifications_screen.dart'; // Replace with actual import if different

void main() {
  runApp(MaterialApp(
    home: MedicationsScreen(
      userEmail: "example@email.com",
      userInitials: "E",
    ),
  ));
}

// LoginScreen (unchanged)
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      const Text("Remember me"),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    String email = emailController.text.trim();
                    if (email.isNotEmpty) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicationsScreen(
                            userEmail: email,
                            userInitials: '',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your email")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("or Login with"),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {},
                child: Image.asset(
                  "assets/images/download__4_-removebg-preview.png",
                  height: 40,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "SignUp",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FAQsScreen (unchanged)
class FAQsScreen extends StatefulWidget {
  const FAQsScreen({Key? key}) : super(key: key);

  @override
  _FAQsScreenState createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredFaqs = [];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Where are you located?',
      'answer': 'We are located in Nateete, Uganda, near the city center.'
    },
    {
      'question': 'May I know your working hours?',
      'answer': 'We are open from 8:00 AM to 8:00 PM, Monday through Saturday.'
    },
    {
      'question': 'How may I contact Winal drug shop?',
      'answer': 'You can contact us on 0701550075'
    },
    {
      'question': 'Which delivery options are available?',
      'answer': 'We offer delivery through public taxis and buses, as well as private courier services.'
    },
    {
      'question': 'Who is responsible for the damages to orders delivered through public means?',
      'answer': 'We ensure secure packaging but are not liable for damages caused by third-party transportation.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _faqs;
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqs = _faqs.where((faq) {
        return faq['question']!.toLowerCase().contains(query) ||
               faq['answer']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'FAQs',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search.....",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFaqs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(_filteredFaqs[index]['question']!),
                            content: Text(_filteredFaqs[index]['answer']!),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 239),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _filteredFaqs[index]['question']!,
                          style: const TextStyle(
                            color:  Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FeedbackScreen (unchanged)
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Feedback', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Rate your experience:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Excellent', 'Good', 'Average', 'Fair', 'Poor']
                  .map((rating) => Row(
                        children: [
                          Radio(value: rating, groupValue: null, onChanged: (value) {}),
                          Text(rating),
                        ],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your comment here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your feedback!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// HealthTipsScreen (unchanged)
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
      'description': 'Drink plenty of water daily to keep your skin glowing and your body energized during festive celebrations.',
      'tip': '💧 Tip: Pair with our hydrating skincare products for radiant skin!',
    },
    {
      'image': 'assets/images/DIET.jpeg',
      'title': 'Eat a balanced diet',
      'description': 'Include fruits, vegetables, and lean proteins in your meals to stay healthy and energetic.',
      'tip': null,
    },
    {
      'image': 'assets/images/WALK.jpeg',
      'title': 'Stay Active',
      'description': 'Take walks or participate in family activities to stay fit while enjoying the season.',
      'tip': '🏃‍♂️ Tip: Support your joints with our wellness supplements.',
    },
    {
      'image': 'assets/images/IMMUNITY.jpeg',
      'title': 'Boost your immunity',
      'description': 'Stock up on vitamin C and zinc to boost your immunity and stay healthy.',
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
            CarouselSlider.builder(
              itemCount: healthTips.length,
              itemBuilder: (context, index, realIndex) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          healthTips[index]['image'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        healthTips[index]['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        healthTips[index]['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      if (healthTips[index]['tip'] != null)
                        Text(
                          healthTips[index]['tip'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                );
              },
              options: CarouselOptions(
                height: 350,
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
          ],
        ),
      ),
    );
  }
}

// AboutUsScreen (unchanged)
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About Us', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Welcome to Winal Drug Shop, your trusted partner in veterinary and agricultural health solutions...'),
            SizedBox(height: 20),
            Text('Contact Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Phone: +256 704550075'),
            Text('Email: winaldrugshop@gmail.com'),
            Text('Location: Nateete, Uganda'),
            SizedBox(height: 20),
            Text('Terms and Conditions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('1. General Information\nWinal Drug Shop provides a wide range of medications...'),
          ],
        ),
      ),
    );
  }
}

// FarmActivitiesScreen
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
      backgroundColor: Colors.white, // Set background color to white to match the image
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Farm Activities', // Uppercase to match the image
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, // Bold to match the image
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0), // Keep the reduced padding
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 30, // Spacing between columns
            mainAxisSpacing: 30, // Spacing between rows
            childAspectRatio: 0.7, // Adjusted to make images slightly larger and fit better
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
          height: 130, // Slightly increased height to match the image proportions
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            image: DecorationImage(
              image: AssetImage(imagePath), // Use the image path (untouched as requested)
              fit: BoxFit.cover, // Ensure the image covers the container
            ),
          ),
        ),
        const SizedBox(height: 4.0), // Space between image and label
        // Label text
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Ensure text is black to match the image
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
// MedicationsScreen (updated with FarmActivitiesScreen in drawer)
class MedicationsScreen extends StatefulWidget {
  final String userEmail;
  final String userInitials;

  const MedicationsScreen({
    Key? key,
    required this.userEmail,
    required this.userInitials,
  }) : super(key: key);

  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CallScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String getInitials(String email) {
    if (email.isEmpty) return "?";
    List<String> parts = email.split('@');
    return parts[0].substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      getInitials(widget.userEmail),
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.userEmail,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety),
              title: const Text('Health Tips'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthTipsScreen()));
              },
            ),
            // Added Farm Activities to the drawer
            ListTile(
              leading: const Icon(Icons.agriculture),
              title: const Text('Farm Activities'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => FarmActivitiesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Medications",
          style: TextStyle(color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              getInitials(widget.userEmail),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryItem(
              "Animal Meds",
              "assets/images/CAT 7.jpeg",
              context,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimalMedsScreen(
                      userEmail: widget.userEmail,
                      userInitials: getInitials(widget.userEmail),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildCategoryItem(
              "Human Meds",
              "assets/images/HUMAN 1.jpeg",
              context,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineApp(
                      userEmail: widget.userEmail,
                      userInitials: getInitials(widget.userEmail),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: "Call"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String imagePath, BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

