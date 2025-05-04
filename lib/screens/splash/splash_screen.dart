import 'dart:async';
import 'package:flutter/material.dart';
import 'slide_screen.dart'; // Import màn hình slide

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Chuyển màn hình sau 3 giây với hiệu ứng mờ dần
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
          const SlideScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Beestyle',
              style: TextStyle(
                fontSize: 48, // Adjust size to match the image
                fontWeight: FontWeight.bold, // Bold for "Beestyle"
                color: Colors.grey[600], // Match the grey color in the image
                fontFamily: 'YourFontFamily', // Replace with the font used in the image if known
              ),
            ),
            const SizedBox(height: 8), // Space between the two texts
            Text(
              'Fashion Shopping',
              style: TextStyle(
                fontSize: 16, // Smaller size for "Fashion Shopping"
                fontWeight: FontWeight.normal,
                color: Colors.grey[600], // Same grey color
                fontFamily: 'YourFontFamily', // Replace with the font used in the image if known
              ),
            ),
          ],
        ),
      ),
    );
  }
}