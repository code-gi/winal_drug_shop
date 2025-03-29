import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/screens/welcome_screen.dart' hide SplashScreen;
import 'package:winal_front_end/screens/splash_screen.dart';
import 'package:winal_front_end/screens/sign_up_screen.dart' hide LoginScreen;
import 'package:winal_front_end/screens/login_screen.dart' as login;
import 'package:winal_front_end/screens/medications_screen.dart'
    hide FarmActivitiesScreen;
import 'package:winal_front_end/screens/animal_medications.dart';
import 'package:winal_front_end/screens/human_medications.dart';
import 'package:winal_front_end/screens/about_us_screen.dart' as aus;
import 'package:winal_front_end/screens/call_screen.dart';
import 'package:winal_front_end/screens/chat_screen.dart';
import 'package:winal_front_end/screens/notifications_screen.dart';
import 'package:winal_front_end/screens/farm_activities_screen.dart';
import 'package:winal_front_end/screens/checkout_screen.dart';
import 'package:winal_front_end/screens/faqs_screen.dart';
import 'package:winal_front_end/screens/feedback_screen.dart';
import 'package:winal_front_end/screens/health_tips_screen.dart';
import 'package:winal_front_end/screens/profile_screen.dart';
import 'package:winal_front_end/utils/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winal Drug Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const login.LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/medications': (context) =>
            const MedicationsScreen(userEmail: '', userInitials: ''),
        '/about_us': (context) => const aus.AboutUsScreen(),
        '/call': (context) => const CallScreen(),
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/farm_activities': (context) => FarmActivitiesScreen(),
        '/checkout': (context) => CheckoutScreen(
              cart: const [],
              totalPrice: 0,
            ),
        '/faqs': (context) => const FAQsScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/health_tips': (context) => const HealthTipsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
