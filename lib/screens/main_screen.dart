import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../routes.dart';
import '../providers/category_provider.dart';
import '../providers/notification_provider.dart'; // Thêm NotificationProvider
import '../core/api/auth_service.dart'; // Để lấy token

// Các màn hình con
import 'home/home_screen.dart';
import 'home/filter_screen.dart';
import 'home/featured_products_screen.dart';
import 'home/cart_screen.dart';
import 'home/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Tải danh mục khi khởi tạo MainScreen
    Provider.of<CategoryProvider>(context, listen: false).loadCategories();

    // Tải thông báo khi khởi tạo MainScreen
    final authService = AuthService();
    authService.getToken().then((token) {
      if (token != null) {
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications(token);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  final List<Widget> _screens = [
    const KeepAliveScreen(child: HomeScreen()),
    const KeepAliveScreen(child: FilterScreen()),
    const KeepAliveScreen(child: FeaturedProductsScreen()),
    const KeepAliveScreen(child: CartScreen()),
    const KeepAliveScreen(child: ProfileScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "BeeStyle",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cursive',
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              // Đếm số thông báo chưa đọc
              final unreadCount = notificationProvider.notifications
                  .where((notification) => !notification.isRead)
                  .length;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.notification);
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Giữ màn hình con “sống” khi chuyển tab
class KeepAliveScreen extends StatefulWidget {
  final Widget child;
  const KeepAliveScreen({super.key, required this.child});

  @override
  State<KeepAliveScreen> createState() => _KeepAliveScreenState();
}

class _KeepAliveScreenState extends State<KeepAliveScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}