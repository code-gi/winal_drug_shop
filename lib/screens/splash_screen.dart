import 'package:flutter/material.dart';

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
    // Navigate to the next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      // Replace with your actual navigation
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomeScreen()),
      // );
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
            // Custom logo
            SizedBox(
              width: 100,
              height: 60,
              child: CustomPaint(
                painter: CowLogoPainter(),
              ),
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

// Custom painter for the cow and wave logo
class CowLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final bluePaint = Paint()
      ..color = const Color(0xFF00A2FF).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Draw cow body
    final cowPath = Path();
    cowPath.moveTo(size.width * 0.3, size.height * 0.17);
    cowPath.cubicTo(
      size.width * 0.25, size.height * 0.17,
      size.width * 0.2, size.height * 0.25,
      size.width * 0.15, size.height * 0.42
    );
    cowPath.cubicTo(
      size.width * 0.1, size.height * 0.58,
      size.width * 0.1, size.height * 0.75,
      size.width * 0.15, size.height * 0.75
    );
    cowPath.cubicTo(
      size.width * 0.2, size.height * 0.75,
      size.width * 0.25, size.height * 0.67,
      size.width * 0.25, size.height * 0.58
    );
    cowPath.lineTo(size.width * 0.3, size.height * 0.58);
    cowPath.lineTo(size.width * 0.3, size.height * 0.67);
    cowPath.cubicTo(
      size.width * 0.3, size.height * 0.75,
      size.width * 0.35, size.height * 0.83,
      size.width * 0.4, size.height * 0.83
    );
    cowPath.cubicTo(
      size.width * 0.45, size.height * 0.83,
      size.width * 0.5, size.height * 0.75,
      size.width * 0.5, size.height * 0.67
    );
    cowPath.lineTo(size.width * 0.5, size.height * 0.58);
    cowPath.lineTo(size.width * 0.55, size.height * 0.58);
    cowPath.lineTo(size.width * 0.55, size.height * 0.67);
    cowPath.cubicTo(
      size.width * 0.55, size.height * 0.75,
      size.width * 0.6, size.height * 0.83,
      size.width * 0.65, size.height * 0.83
    );
    cowPath.cubicTo(
      size.width * 0.7, size.height * 0.83,
      size.width * 0.75, size.height * 0.75,
      size.width * 0.75, size.height * 0.67
    );
    cowPath.lineTo(size.width * 0.75, size.height * 0.58);
    cowPath.lineTo(size.width * 0.8, size.height * 0.58);
    cowPath.cubicTo(
      size.width * 0.8, size.height * 0.67,
      size.width * 0.85, size.height * 0.75,
      size.width * 0.9, size.height * 0.75
    );
    cowPath.cubicTo(
      size.width * 0.95, size.height * 0.75,
      size.width * 0.95, size.height * 0.58,
      size.width * 0.9, size.height * 0.42
    );
    cowPath.cubicTo(
      size.width * 0.85, size.height * 0.25,
      size.width * 0.8, size.height * 0.17,
      size.width * 0.75, size.height * 0.17
    );
    cowPath.lineTo(size.width * 0.3, size.height * 0.17);
    cowPath.close();
    
    // Draw cow horns
    final leftHornPath = Path();
    leftHornPath.moveTo(size.width * 0.3, size.height * 0.17);
    leftHornPath.cubicTo(
      size.width * 0.3, size.height * 0.08,
      size.width * 0.25, size.height * 0.08,
      size.width * 0.25, size.height * 0.17
    );
    leftHornPath.lineTo(size.width * 0.3, size.height * 0.17);
    leftHornPath.close();
    
    final rightHornPath = Path();
    rightHornPath.moveTo(size.width * 0.75, size.height * 0.17);
    rightHornPath.cubicTo(
      size.width * 0.75, size.height * 0.08,
      size.width * 0.8, size.height * 0.08,
      size.width * 0.8, size.height * 0.17
    );
    rightHornPath.lineTo(size.width * 0.75, size.height * 0.17);
    rightHornPath.close();
    
    // Draw the blue wave
    final wavePath = Path();
    wavePath.moveTo(size.width * 0.25, size.height * 0.58);
    wavePath.cubicTo(
      size.width * 0.35, size.height * 0.42,
      size.width * 0.45, size.height * 0.67,
      size.width * 0.55, size.height * 0.5
    );
    wavePath.cubicTo(
      size.width * 0.65, size.height * 0.33,
      size.width * 0.75, size.height * 0.58,
      size.width * 0.85, size.height * 0.42
    );
    wavePath.cubicTo(
      size.width * 0.95, size.height * 0.25,
      size.width * 0.95, size.height * 0.75,
      size.width * 0.85, size.height * 0.75
    );
    wavePath.cubicTo(
      size.width * 0.75, size.height * 0.75,
      size.width * 0.65, size.height * 0.75,
      size.width * 0.55, size.height * 0.75
    );
    wavePath.cubicTo(
      size.width * 0.45, size.height * 0.75,
      size.width * 0.35, size.height * 0.75,
      size.width * 0.25, size.height * 0.75
    );
    wavePath.cubicTo(
      size.width * 0.15, size.height * 0.75,
      size.width * 0.15, size.height * 0.75,
      size.width * 0.25, size.height * 0.58
    );
    wavePath.close();
    
    // Draw all the paths
    canvas.drawPath(cowPath, blackPaint);
    canvas.drawPath(leftHornPath, blackPaint);
    canvas.drawPath(rightHornPath, blackPaint);
    canvas.drawPath(wavePath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}