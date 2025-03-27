import 'package:flutter/material.dart';
import 'package:winal_front_end/screens/welcome_screen.dart';
import 'login_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Winal Drug Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      // Replace with actual navigation
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the logo image
            SizedBox(
              width: 100,
              height: 50,
              child: Image.asset('assets/images/Screenshot_2024-11-08_at_20.10.04-removebg-preview (1).png'), // Image path
            ),
            const SizedBox(height: 15),
            // Shop name
            const Text(
              'WINAL DRUG SHOP',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
