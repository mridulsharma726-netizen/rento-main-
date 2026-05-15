import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final ApiService _api = ApiService();
  final _storage = const FlutterSecureStorage();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<void> init() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _api.setAuthToken(session.accessToken);
      await refreshProfile();
    }
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      _api.setAuthToken(response.session?.accessToken);
      return await refreshProfile();
    }
    throw Exception('Login failed');
  }

  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );

    if (response.user != null) {
      _api.setAuthToken(response.session?.accessToken);
      return await refreshProfile();
    }
    throw Exception('Registration failed');
  }

  Future<UserModel> refreshProfile() async {
    final response = await _api.getProfile();
    _currentUser = UserModel.fromJson(response['user']);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(response['user']));
    
    return _currentUser!;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _api.setAuthToken(null);
    _currentUser = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await _storage.delete(key: 'jwt_token');
  }
}
