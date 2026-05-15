import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'models/booking_model.dart';
import 'models/product_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_screen.dart';

import 'screens/booking/booking_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/payment/payment_screen.dart';
import 'screens/product/add_product_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/my_products_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/kyc/kyc_screen.dart';
import 'screens/support/support_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/splash/splash_screen.dart';

class RentoApp extends StatelessWidget {
  const RentoApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RENTO',
      scaffoldMessengerKey: messengerKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fade(const SplashScreen());

      case '/login':
        return _slide(const LoginScreen());

      case '/home':
        return _fade(const HomeScreen());

      case '/product':
        final id = settings.arguments as String;
        return _slide(ProductDetailScreen(productId: id));

      case '/add-product':
        return _slide(const AddProductScreen());

      case '/booking':
        final args = settings.arguments as Map<String, dynamic>;
        return _slide(BookingScreen(
          product: args['product'] as ProductModel,
          startDate: args['start_date'] as DateTime,
          endDate: args['end_date'] as DateTime,
        ));

      case '/payment':
        final booking = settings.arguments as BookingModel;
        return _slide(PaymentScreen(booking: booking));

      case '/orders':
        return _slide(const OrdersScreen());

      case '/booking-detail':
        return _slide(const OrdersScreen());

      case '/profile':
        return _slide(const ProfileScreen());

      case '/edit-profile':
        return _slide(const EditProfileScreen());

      case '/my-rentals':
        return _slide(const OrdersScreen(initialTab: 0));

      case '/my-products':
        return _slide(const MyProductsScreen());

      case '/settings':
        return _slide(const SettingsScreen());

      case '/kyc':
        return _slide(const KycScreen());

      case '/support':
        return _slide(const SupportScreen());

      case '/notifications':
        return _slide(const NotificationsScreen());
        
      case '/chat-list':
        return _slide(const ChatListScreen());

      case '/chat-detail':
        final args = settings.arguments as Map<String, dynamic>;
        return _slide(ChatScreen(
          otherUserId: args['userId'],
          otherUserName: args['userName'],
          productId: args['productId'],
        ));

      default:
        return _fade(const HomeScreen());
    }
  }

  PageRouteBuilder _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: anim.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
