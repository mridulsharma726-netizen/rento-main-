import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/socket_service.dart';
import '../models/user_model.dart';
import '../core/services/push_notification_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _userModel;

  bool _isLoading = false;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    ApiService().onUnauthorized = () => signOut();
    initialized = _initAuth();
  }

  Future<Map<String, dynamic>> testConnection() async {
    return await ApiService().getProducts(limit: 1); // Simple request to test
  }

  late Future<void> initialized;

  Future<void> _initAuth() async {
    try {
      await _authService.init();
      if (_authService.currentUser != null) {
        _userModel = _authService.currentUser;
        _status = AuthStatus.authenticated;
        PushNotificationService.instance.initialize();
        final token = await _authService.getToken();
        if (token != null) SocketService().connect(token);
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.signInWithEmailAndPassword(
          email: email, password: password);
      _userModel = user;
      _status = AuthStatus.authenticated;
      PushNotificationService.instance.initialize();
      final token = await _authService.getToken();
      if (token != null) SocketService().connect(token);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password,
      {String name = 'New User'}) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      _userModel = user;
      _status = AuthStatus.authenticated;
      PushNotificationService.instance.initialize();
      final token = await _authService.getToken();
      if (token != null) SocketService().connect(token);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> googleLogin() async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _userModel = user;
        _status = AuthStatus.authenticated;
        PushNotificationService.instance.initialize();
        final token = await _authService.getToken();
        if (token != null) SocketService().connect(token);
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    SocketService().disconnect();
    await _authService.signOut();
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.updateProfile(data);
      _userModel = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.changePassword(currentPassword, newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>?> getKycStatus() async {
    _setLoading(true);
    _clearError();
    try {
      final res = await _authService.getKycStatus();
      _setLoading(false);
      return res;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return null;
    }
  }

  Future<bool> uploadKyc(Map<String, dynamic> data, {String? imagePath}) async {
    _setLoading(true);
    _clearError();
    try {
      final res = await _authService.uploadKyc(data, imagePath: imagePath);
      // Update local user status
      if (res['success'] == true) {
        await _authService.refreshProfile();
        _userModel = _authService.currentUser;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      _userModel = await _authService.refreshProfile();
      notifyListeners();
    } catch (_) {
      // Keep current local state if refresh is not available.
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() => _clearError();
}
