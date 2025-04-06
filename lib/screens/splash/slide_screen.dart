import 'package:flutter/material.dart';
import '../../routes.dart'; // Import file routes nếu bạn dùng AppRoutes.login
// Hoặc import LoginScreen() nếu bạn có màn hình Login riêng

class SlideScreen extends StatefulWidget {
  const SlideScreen({Key? key}) : super(key: key);

  @override
  State<SlideScreen> createState() => _SlideScreenState();
}

class _SlideScreenState extends State<SlideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Mảng chứa đường dẫn ảnh
  final List<String> images = [
    'assets/images/spl1.jpg',
    'assets/images/spl2.jpg',
    'assets/images/spl3.jpg',
    'assets/images/spl4.jpg',
  ];

  // Hàm cập nhật chỉ số trang
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // Hàm tạo route Fade Transition (chuyển cảnh mượt)
  Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: 0.0, end: 1.0);
        final fadeAnimation = animation.drive(tween);
        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  // Khi bấm Skip
  void _skipOnboarding() {
    // Cách 1: Dùng route name (nếu bạn có AppRoutes.login)
    Navigator.pushReplacementNamed(context, AppRoutes.login);

    // Hoặc Cách 2: Nếu bạn có LoginScreen():
    // Navigator.of(context).pushReplacement(
    //   _createFadeRoute(const LoginScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // PageView hiển thị ảnh
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return Image.asset(
                  images[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),

            // Nút Skip ở góc trên bên phải
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Thanh chấm tròn ở dưới
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}