import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _userId;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  bool get isLoggedIn => _isLoggedIn;

  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/users';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/users';
    } else {
      return 'http://localhost:9000/api/users';
    }
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString(_userIdKey);
      _isLoggedIn = _userId != null;
      print('AuthService initialized - User ID: $_userId, isLoggedIn: $_isLoggedIn');
      
      if (_userId == null) {
        print('No user ID found in SharedPreferences');
        // 如果没有用户ID，清除所有认证相关的数据
        await logout();
      }
    } catch (e) {
      print('Error initializing AuthService: $e');
      _isLoggedIn = false;
      _userId = null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _isLoggedIn = true;
  }

  Future<void> checkLoginStatus() async {
    final token = await getToken();
    _isLoggedIn = token != null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final body = json.encode({'email': email, 'password': password});

    try {
      print('Login attempt - URL: $url');
      print('Request body: $body');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['id'] == null) {
          throw Exception('Server response missing user ID');
        }
        
        _userId = data['id'];
        _isLoggedIn = true;
        
        // Save user ID to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userIdKey, _userId!);
        print('User logged in successfully - ID: $_userId');
        
        return data;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error de autenticació');
      }
    } catch (e) {
      print('Login error: $e');
      // 确保在登录失败时清除所有状态
      _userId = null;
      _isLoggedIn = false;
      throw Exception('Error de connexió: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_tokenKey);
      _isLoggedIn = false;
      _userId = null;
      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Error al tancar sessió: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      if (_userId == null) {
        throw Exception('No user ID available');
      }

      final url = Uri.parse('$_baseUrl/$_userId');
      print('Getting user profile - URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al carregar el perfil');
      }
    } catch (e) {
      print('Get profile error: $e');
      throw Exception('Error de connexió: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    try {
      if (_userId == null) {
        throw Exception('No user ID available');
      }

      final url = Uri.parse('$_baseUrl/$_userId/perfil');
      print('Updating profile - URL: $url');
      print('Update data: $userData');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al actualitzar el perfil');
      }
    } catch (e) {
      print('Update profile error: $e');
      throw Exception('Error de connexió: $e');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      if (_userId == null) {
        throw Exception('No user ID available');
      }

      final url = Uri.parse('$_baseUrl/$_userId/password');
      print('Changing password - URL: $url');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'oldPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      print('Change password response status: ${response.statusCode}');
      print('Change password response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al canviar la contrasenya');
      }
    } catch (e) {
      print('Change password error: $e');
      throw Exception('Error de connexió: $e');
    }
  }

  // Helper method to get user ID from login response
  String? getUserId() {
    try {
      return _userId;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }
}

