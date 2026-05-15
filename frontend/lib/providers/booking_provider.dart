import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<BookingModel> _rentals = [];
  List<BookingModel> _listings = [];
  BookingModel? _currentBooking;
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get rentals => _rentals;
  List<BookingModel> get listings => _listings;
  BookingModel? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserBookings() async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _api.getUserBookings();
      _rentals = (res['data']?['bookings'] as List<dynamic>? ?? [])
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load rentals';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOwnerBookings() async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _api.getOwnerBookings();
      _listings = (res['data']?['bookings'] as List<dynamic>? ?? [])
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load listings';
    } finally {
      _setLoading(false);
    }
  }

  Future<BookingModel?> createBooking({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _api.createBooking({
        'product_id': productId,
        'start_date': startDate.toUtc().toIso8601String(),
        'end_date': endDate.toUtc().toIso8601String(),
      });
      final booking =
          BookingModel.fromJson(res['data']['booking'] as Map<String, dynamic>);
      _currentBooking = booking;
      _rentals.insert(
          0, booking); // New booking is always a rental for the creator
      notifyListeners();
      return booking;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (_) {
      _error = 'Failed to create booking';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.cancelBooking(bookingId);

      // Update status in-place — no list reconstruction
      for (int i = 0; i < _rentals.length; i++) {
        if (_rentals[i].id == bookingId) {
          _rentals[i] = _rentals[i].copyWith(status: 'cancelled');
          break;
        }
      }
      for (int i = 0; i < _listings.length; i++) {
        if (_listings[i].id == bookingId) {
          _listings[i] = _listings[i].copyWith(status: 'cancelled');
          break;
        }
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Failed to cancel booking';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Returns the generated OTP string so the owner can show it
  Future<String?> generateOtp(String bookingId) async {
    try {
      final res = await _api.generateOtp(bookingId);
      return res['data']?['otp'] as String?;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> approveBooking(String bookingId) async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _api.approveBooking(bookingId);
      final booking =
          BookingModel.fromJson(res['data']['booking'] as Map<String, dynamic>);
      _replaceBooking(booking);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Failed to approve booking';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectBooking(String bookingId, {String? reason}) async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _api.rejectBooking(bookingId, reason: reason);
      final booking =
          BookingModel.fromJson(res['data']['booking'] as Map<String, dynamic>);
      _replaceBooking(booking);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Failed to reject booking';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Returns true on success — booking moves to 'active'
  Future<bool> verifyOtp(String bookingId, String otp) async {
    try {
      await _api.verifyHandoverOtp(bookingId, otp);
      for (int i = 0; i < _rentals.length; i++) {
        if (_rentals[i].id == bookingId) {
          _rentals[i] = _rentals[i].copyWith(status: 'active');
          break;
        }
      }
      for (int i = 0; i < _listings.length; i++) {
        if (_listings[i].id == bookingId) {
          _listings[i] = _listings[i].copyWith(status: 'active');
          break;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> initiateReturn(String bookingId) async {
    try {
      final res = await _api.returnItem(bookingId);
      final returnId = res['data']?['return_id']?.toString();
      _updateBooking(bookingId, status: 'return_pending', returnId: returnId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmReturn(String bookingId) async {
    try {
      await _api
          .confirmReturn({'booking_id': bookingId, 'damage_observed': false});
      _updateBooking(bookingId, status: 'completed');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Called by PaymentScreen after successful Razorpay verification so that
  /// the orders list reflects the new status immediately, without needing a
  /// full server round-trip.
  void markBookingPaid(String bookingId) {
    _updateBooking(bookingId, status: 'paid', paymentStatus: 'paid');
    notifyListeners();
  }

  void setCurrentBooking(BookingModel booking) {
    _currentBooking = booking;
    notifyListeners();
  }

  void _replaceBooking(BookingModel booking) {
    _currentBooking = booking;
    _replaceInList(_rentals, booking);
    _replaceInList(_listings, booking);
  }

  void _replaceInList(List<BookingModel> bookings, BookingModel booking) {
    final index = bookings.indexWhere((item) => item.id == booking.id);
    if (index >= 0) {
      bookings[index] = booking;
    } else {
      bookings.insert(0, booking);
    }
  }

  void _updateBooking(String bookingId,
      {String? status, String? paymentStatus, String? returnId}) {
    for (int i = 0; i < _rentals.length; i++) {
      if (_rentals[i].id == bookingId) {
        _rentals[i] = _rentals[i].copyWith(
          status: status,
          paymentStatus: paymentStatus,
          returnId: returnId,
        );
        break;
      }
    }
    for (int i = 0; i < _listings.length; i++) {
      if (_listings[i].id == bookingId) {
        _listings[i] = _listings[i].copyWith(
          status: status,
          paymentStatus: paymentStatus,
          returnId: returnId,
        );
        break;
      }
    }
    if (_currentBooking?.id == bookingId) {
      _currentBooking = _currentBooking?.copyWith(
        status: status,
        paymentStatus: paymentStatus,
        returnId: returnId,
      );
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
