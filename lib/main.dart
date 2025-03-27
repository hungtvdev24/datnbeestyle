import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các provider
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/address_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/myorder_provider.dart';
import 'providers/favorite_product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/recent_products_provider.dart'; // Thêm RecentProductsProvider
import 'providers/review_provider.dart'; // Thêm ReviewProvider

// Import file routes
import 'routes.dart';

// Khai báo routeObserver nếu cần
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
        ChangeNotifierProvider(create: (context) => CheckoutProvider()),
        ChangeNotifierProvider(create: (context) => MyOrderProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProductProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => RecentProductsProvider()), // Thêm RecentProductsProvider
        ChangeNotifierProvider(create: (context) => ReviewProvider()), // Thêm ReviewProvider
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
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng bán hàng',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.splash,
      routes: appRoutes,
      navigatorObservers: [
        routeObserver,
      ],
    );
  }
}