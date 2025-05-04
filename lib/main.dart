import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
import 'providers/recent_products_provider.dart';
import 'providers/review_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/voucher_provider.dart'; // Thêm VoucherProvider

// Import file routes
import 'routes.dart';

// Khai báo routeObserver nếu cần
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
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
        ChangeNotifierProvider(create: (context) => RecentProductsProvider()),
        ChangeNotifierProvider(create: (context) => ReviewProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => VoucherProvider()), // Thêm VoucherProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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