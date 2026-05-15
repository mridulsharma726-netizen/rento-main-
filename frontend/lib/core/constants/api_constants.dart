import 'package:flutter/foundation.dart';

/// Backend API endpoint constants.
/// Update [baseUrl] for production deployment.
class ApiConstants {
  ApiConstants._();

  // Override at runtime with:
  // flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000/api
  static const String _overrideUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const String _emulatorUrl = 'http://192.168.1.12:3000/api';
  static const String _localhostUrl = 'http://192.168.1.12:3000/api';
  static const String _prodUrl = 'https://rento-api.yourdomain.com/api';

  // Toggle this for production
  static const bool isProduction = false;

  static String get baseUrl {
    if (_overrideUrl.isNotEmpty) {
      return _overrideUrl.endsWith('/')
          ? _overrideUrl.substring(0, _overrideUrl.length - 1)
          : _overrideUrl;
    }
    if (isProduction) return _prodUrl;
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      final scheme =
          (host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0')
              ? 'http'
              : Uri.base.scheme;
      return '$scheme://$host:3000/api';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? _emulatorUrl
        : _localhostUrl;
  }

  // Products
  static const String products = '/products';
  static const String myProducts = '/products/my';
  static String productById(String id) => '/products/$id';

  // Profile
  static const String profile = '/profile';
  static const String changePassword = '/profile/password';

  // Support
  static const String support = '/support';

  // Notifications
  static const String notifications = '/notifications';
  static const String markAllRead = '/notifications/read-all';
  static String markRead(String id) => '/notifications/$id/read';

  // Bookings
  static const String bookings = '/bookings';
  static const String myRentals = '/bookings/user';
  static const String myListingsBookings = '/bookings/owner';
  static String bookingDetails(String id) => '/bookings/$id/details';
  static String approveBooking(String id) => '/bookings/$id/approve';
  static String rejectBooking(String id) => '/bookings/$id/reject';
  static String cancelBooking(String id) => '/bookings/$id/cancel';

  // Payments
  static const String createOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  static String paymentByBooking(String bookingId) => '/payments/$bookingId';

  // Handover / OTP
  static const String generateOtp = '/handover/generate-otp';
  static const String verifyOtp = '/handover/verify-otp';
  static const String resendOtp = '/handover/resend-otp';

  // Return
  static const String returnItem = '/return/return-item';
  static const String confirmReturn = '/return/confirm-return';
  static String returnStatus(String bookingId) => '/return/$bookingId';

  // Ratings
  static const String rateUser = '/ratings/rate-user';
  static String userRatings(String userId) => '/ratings/user/$userId';

  // KYC
  static const String uploadKyc = '/kyc/upload-id-proof';
  static const String kycStatus = '/kyc/status';

  // Chat
  static const String chatList = '/chat/list';
  static String chatConversation(String otherId) =>
      '/chat/conversation/$otherId';
  static const String chatSend = '/chat/send';

  // Health
  static const String health = '/health';
}
