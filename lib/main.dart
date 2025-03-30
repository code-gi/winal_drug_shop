import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/screens/welcome_screen.dart' hide SplashScreen;
import 'package:winal_front_end/screens/splash_screen.dart';
import 'package:winal_front_end/screens/sign_up_screen.dart' hide LoginScreen;
import 'package:winal_front_end/screens/login_screen.dart' as login;
// import 'package:winal_front_end/screens/human_medications.dart';
// import 'package:winal_front_end/screens/animal_medications.dart';
import 'package:winal_front_end/screens/dynamic_medications.dart';
import 'package:winal_front_end/screens/medication_detail_screen.dart';
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
import 'package:winal_front_end/screens/dashboard_screen.dart';
import 'package:winal_front_end/utils/auth_provider.dart';
import 'package:winal_front_end/utils/medication_provider.dart';
import 'package:winal_front_end/providers/cart_provider.dart';
import 'package:winal_front_end/screens/admin/admin_dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
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
      // We can't register screens with required parameters directly in routes
      onGenerateRoute: (settings) {
        if (settings.name == '/medication_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MedicationDetailScreen(
              medicationId: args['medicationId'],
            ),
          );
        } else if (settings.name == '/admin') {
          // Admin dashboard route
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              args['adminName'] == null ||
              args['adminEmail'] == null) {
            // If arguments are missing, redirect to login
            return MaterialPageRoute(
              builder: (context) => const login.LoginScreen(),
            );
          }
          return MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(
              adminName: args['adminName'],
              adminEmail: args['adminEmail'],
            ),
          );
        } else if (settings.name == '/dashboard') {
          // Check if args exists and contains required fields
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || args['userEmail'] == null) {
            // If argument is missing, redirect to login
            return MaterialPageRoute(
              builder: (context) => const login.LoginScreen(),
            );
          }
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userEmail: args['userEmail'],
              userInitials: args['userInitials'] ?? '',
            ),
          );
        }

        // else if (settings.name == '/human_medications') {
        //   // Check if args exists and contains required fields
        //   final args = settings.arguments as Map<String, dynamic>?;
        //   if (args == null || args['userEmail'] == null) {
        //     // If argument is missing, redirect to login
        //     return MaterialPageRoute(
        //       builder: (context) => const login.LoginScreen(),
        //     );
        //   }
        //   return MaterialPageRoute(
        //     builder: (context) => HumanMedicationsScreen(
        //       userEmail: args['userEmail'],
        //       userInitials: args['userInitials'] ?? '',
        //     ),
        //   );
        // } else if (settings.name == '/animal_medications') {
        //   // Check if args exists and contains required fields
        //   final args = settings.arguments as Map<String, dynamic>?;
        //   if (args == null || args['userEmail'] == null) {
        //     // If argument is missing, redirect to login
        //     return MaterialPageRoute(
        //       builder: (context) => const login.LoginScreen(),
        //     );
        //   }
        //   return MaterialPageRoute(
        //     builder: (context) => AnimalMedsScreen(
        //       userEmail: args['userEmail'],
        //       userInitials: args['userInitials'] ?? '',
        //     ),
        //   );
        // }

        else if (settings.name == '/dynamic_medications') {
          // Check if args exists and contains required fields
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              args['userEmail'] == null ||
              args['medicationType'] == null) {
            // If required arguments are missing, redirect to login
            return MaterialPageRoute(
              builder: (context) => const login.LoginScreen(),
            );
          }
          return MaterialPageRoute(
            builder: (context) => DynamicMedicationsScreen(
              userEmail: args['userEmail'],
              userInitials: args['userInitials'] ?? '',
              medicationType: args['medicationType'],
              screenTitle: args['screenTitle'] ??
                  args['medicationType'].toString().toUpperCase() +
                      ' Medications',
            ),
          );
        }
        return null;
      },
    );
  }
}
