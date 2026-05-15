import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// HTTP API service — wraps all backend calls.
/// Call [setAuthToken] after sign-in.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  void Function()? onUnauthorized;

  void setAuthToken(String? token) => _authToken = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Uri _uri(String path) {
    final url = '${ApiConstants.baseUrl}$path';
    debugPrint('🚀 [API REQ] $url');
    return Uri.parse(url);
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    debugPrint('📩 [API RES] ${res.statusCode} ${res.request?.url}');

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    if (res.statusCode == 401) {
      onUnauthorized?.call();
    }

    throw ApiException(
      message: body['error'] ?? body['message'] ?? 'Unknown error',
      code: body['code'] ?? 'UNKNOWN',
      statusCode: res.statusCode,
    );
  }

  // Global timeout for all requests
  static const _timeout = Duration(seconds: 10);

  // ── Products ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'all')
        'category': category,
      if (minPrice != null) 'min_price': '$minPrice',
      if (maxPrice != null) 'max_price': '$maxPrice',
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.products}')
        .replace(queryParameters: params);
    debugPrint('🚀 [API REQ] GET $uri');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    final res = await http
        .get(_uri(ApiConstants.productById(id)), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data,
      {String? imagePath, List<int>? imageBytes, String? imageName}) async {
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final request =
          http.MultipartRequest('POST', _uri(ApiConstants.products));
      request.headers.addAll({
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      data.forEach((key, value) => request.fields[key] = value.toString());
      request.files.add(http.MultipartFile.fromBytes('images', imageBytes,
          filename: imageName ?? 'image.jpg'));
      final streamedResponse = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamedResponse);
      return _handleResponse(res);
    } else {
      final res = await http
          .post(_uri(ApiConstants.products),
              headers: _headers, body: jsonEncode(data))
          .timeout(_timeout);
      return _handleResponse(res);
    }
  }

  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> data,
      {String? imagePath, List<int>? imageBytes, String? imageName}) async {
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final request =
          http.MultipartRequest('PUT', _uri(ApiConstants.productById(id)));
      request.headers.addAll({
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      data.forEach((key, value) => request.fields[key] = value.toString());
      request.files.add(http.MultipartFile.fromBytes('images', imageBytes,
          filename: imageName ?? 'image.jpg'));
      final streamedResponse = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamedResponse);
      return _handleResponse(res);
    } else {
      final res = await http
          .put(_uri(ApiConstants.productById(id)),
              headers: _headers, body: jsonEncode(data))
          .timeout(_timeout);
      return _handleResponse(res);
    }
  }

  Future<Map<String, dynamic>> deleteProduct(String id) async {
    final res = await http
        .delete(_uri(ApiConstants.productById(id)), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getMyProducts() async {
    final res = await http
        .get(_uri(ApiConstants.myProducts), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Bookings ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    final res = await http
        .post(_uri(ApiConstants.bookings),
            headers: _headers, body: jsonEncode(data))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getUserBookings({String? status}) async {
    final params = <String, String>{
      if (status != null) 'status': status,
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myRentals}')
        .replace(queryParameters: params);
    debugPrint('🚀 [API REQ] GET $uri');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getOwnerBookings({String? status}) async {
    final params = <String, String>{
      if (status != null) 'status': status,
    };
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myListingsBookings}')
            .replace(queryParameters: params);
    debugPrint('🚀 [API REQ] GET $uri');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getBookingDetails(String id) async {
    final res = await http
        .get(_uri(ApiConstants.bookingDetails(id)), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> approveBooking(String id) async {
    final res = await http
        .put(_uri(ApiConstants.approveBooking(id)), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> rejectBooking(String id,
      {String? reason}) async {
    final payload = <String, dynamic>{};
    if (reason != null && reason.trim().isNotEmpty) {
      payload['reason'] = reason.trim();
    }
    final res = await http
        .put(
          _uri(ApiConstants.rejectBooking(id)),
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> cancelBooking(String id) async {
    final res = await http
        .put(_uri(ApiConstants.cancelBooking(id)), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createPaymentOrder(String bookingId) async {
    final res = await http
        .post(_uri(ApiConstants.createOrder),
            headers: _headers, body: jsonEncode({'booking_id': bookingId}))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> data) async {
    final res = await http
        .post(_uri(ApiConstants.verifyPayment),
            headers: _headers, body: jsonEncode(data))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getPaymentByBooking(String bookingId) async {
    final res = await http
        .get(_uri(ApiConstants.paymentByBooking(bookingId)), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Handover OTP ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> generateOtp(String bookingId) async {
    final res = await http
        .post(_uri(ApiConstants.generateOtp),
            headers: _headers, body: jsonEncode({'booking_id': bookingId}))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> verifyHandoverOtp(
      String bookingId, String otp) async {
    final res = await http
        .post(_uri(ApiConstants.verifyOtp),
            headers: _headers,
            body: jsonEncode({'booking_id': bookingId, 'otp': otp}))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Return ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> returnItem(String bookingId,
      {List<String>? images}) async {
    final res = await http
        .post(_uri(ApiConstants.returnItem),
            headers: _headers,
            body: jsonEncode(
                {'booking_id': bookingId, 'return_images': images ?? []}))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> confirmReturn(Map<String, dynamic> data) async {
    final res = await http
        .post(_uri(ApiConstants.confirmReturn),
            headers: _headers, body: jsonEncode(data))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Ratings ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> rateUser(Map<String, dynamic> data) async {
    final res = await http
        .post(_uri(ApiConstants.rateUser),
            headers: _headers, body: jsonEncode(data))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getUserRatings(String userId) async {
    final res = await http
        .get(_uri(ApiConstants.userRatings(userId)), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    final res = await http
        .get(_uri(ApiConstants.profile), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await http
        .put(_uri(ApiConstants.profile),
            headers: _headers, body: jsonEncode(data))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    final data = {
      'current_password': currentPassword,
      'new_password': newPassword
    };
    final res = await http
        .put(_uri(ApiConstants.changePassword),
            headers: _headers, body: jsonEncode(data))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Support ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendSupportMessage(String message) async {
    final res = await http
        .post(_uri(ApiConstants.support),
            headers: _headers, body: jsonEncode({'message': message}))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getSupportMessages() async {
    final res = await http
        .get(_uri(ApiConstants.support), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getNotifications() async {
    final res = await http
        .get(_uri(ApiConstants.notifications), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> markNotificationRead(String id) async {
    final res = await http
        .put(_uri(ApiConstants.markRead(id)), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    final res = await http
        .put(_uri(ApiConstants.markAllRead), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getChatList() async {
    final res = await http
        .get(_uri(ApiConstants.chatList), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> getConversation(String otherUserId) async {
    final res = await http
        .get(_uri(ApiConstants.chatConversation(otherUserId)),
            headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    final res = await http
        .post(_uri(ApiConstants.chatSend),
            headers: _headers, body: jsonEncode(data))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ── KYC ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getKycStatus() async {
    final res = await http
        .get(_uri(ApiConstants.kycStatus), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> uploadKyc(Map<String, dynamic> data,
      {String? imagePath}) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      final request =
          http.MultipartRequest('POST', _uri(ApiConstants.uploadKyc));
      request.headers.addAll({
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      request.files
          .add(await http.MultipartFile.fromPath('kyc_image', imagePath));

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);
      return _handleResponse(res);
    } else {
      final res = await http
          .post(_uri(ApiConstants.uploadKyc),
              headers: _headers, body: jsonEncode(data))
          .timeout(_timeout);
      return _handleResponse(res);
    }
  }

  // ── FCM ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> saveFcmToken(String token) async {
    final res = await http
        .post(_uri('/profile/save-token'),
            headers: _headers, body: jsonEncode({'fcmToken': token}))
        .timeout(_timeout);
    return _handleResponse(res);
  }
}

class ApiException implements Exception {
  final String message;
  final String code;
  final int statusCode;
  ApiException(
      {required this.message, required this.code, required this.statusCode});

  @override
  String toString() => 'ApiException[$statusCode/$code]: $message';
}
