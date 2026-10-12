import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isGuest = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null || _isGuest;
  bool get isGuest => _isGuest;

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString('auth_user');
      final savedToken = prefs.getString('auth_token');

      if (savedUser != null && savedToken != null) {
        _api.authToken = savedToken;
        final map = jsonDecode(savedUser);
        _currentUser = UserModel.fromMap(map);
      }
    } catch (e) {
      debugPrint('Error restoring auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _api.login(email, password);
      _currentUser = user;
      _isGuest = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(user.toMap()));
      if (user.token != null) {
        await prefs.setString('auth_token', user.token!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _api.register(name, email, password);
      _currentUser = user;
      _isGuest = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(user.toMap()));
      if (user.token != null) {
        await prefs.setString('auth_token', user.token!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void continueAsGuest() {
    _isGuest = true;
    _currentUser = const UserModel(
      id: 'guest_user',
      name: 'Guest User',
      email: 'guest@local.device',
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isGuest = false;
    _api.authToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
    await prefs.remove('auth_token');

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
