import 'package:flutter/material.dart';

// Các màn hình
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/slide_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile/address_list_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/product/search_screen.dart';
import 'screens/product/notification_screen.dart';
import 'screens/product/category_detail_screen.dart';
import 'screens/product/share_screen.dart';
import 'screens/product/recent_history_screen.dart';
import 'screens/product/review_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/order/order_screen.dart';
import 'screens/profile/chat_screen.dart';
import 'screens/profile/admin_list_screen.dart';
import 'screens/profile/voucher_list_screen.dart'; // Thêm VoucherListScreen

class AppRoutes {
  static const String splash = '/splash';
  static const String slide = '/slide';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String home = '/main';
  static const String addressList = '/address-list';
  static const String editProfile = '/edit-profile';
  static const String order = '/order-list';
  static const String search = '/search';
  static const String notification = '/notification';
  static const String categoryDetail = '/category-detail';
  static const String share = '/share';
  static const String recentHistory = '/recent-history';
  static const String productDetail = '/product-detail';
  static const String review = '/review';
  static const String chat = '/chat';
  static const String adminList = '/admin-list';
  static const String voucherList = '/voucher-list'; // Thêm route mới
}

Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash: (context) => const SplashScreen(),
  AppRoutes.slide: (context) => const SlideScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.register: (context) => const RegisterScreen(),
  AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
  AppRoutes.otp: (context) => const OtpScreen(),
  AppRoutes.home: (context) => const MainScreen(),
  AppRoutes.addressList: (context) => const AddressListScreen(),
  AppRoutes.editProfile: (context) => const EditProfileScreen(),
  AppRoutes.search: (context) => const SearchScreen(),
  AppRoutes.notification: (context) => const NotificationScreen(),
  AppRoutes.order: (context) => const MyOrdersScreen(),
  AppRoutes.categoryDetail: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return CategoryDetailScreen(
      categoryId: args['categoryId'],
      categoryName: args['categoryName'],
    );
  },
  AppRoutes.share: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return ShareScreen(
      title: args?['title'] as String?,
      content: args?['content'] as String?,
      url: args?['url'] as String?,
    );
  },
  AppRoutes.recentHistory: (context) => const RecentHistoryScreen(),
  AppRoutes.productDetail: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ProductDetailScreen(product: args);
  },
  AppRoutes.review: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ReviewScreen(
      orderId: args['orderId'] as int,
      productId: args['productId'] as int,
      variationId: args['variationId'] as int,
    );
  },
  AppRoutes.chat: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ChatScreen(
      receiver: args['receiver'],
    );
  },
  AppRoutes.adminList: (context) => const AdminListScreen(),
  AppRoutes.voucherList: (context) => const VoucherListScreen(), // Thêm route mới
};