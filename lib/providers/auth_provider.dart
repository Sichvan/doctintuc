import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _userId;
  String? _email;

  // final String _baseUrl ='http://10.0.2.2:5000/api';
  final String _baseUrl ='http://10.200.151.26:5000/api';

  bool get isAuth => _token != null;
  String? get token => _token;
  String? get role => _role;
  String? get userId => _userId;
  String? get email => _email;

  Future<void> _authenticate(
      String email, String password, String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        try {
          final responseData = json.decode(response.body);
          throw (responseData['msg'] ?? 'Đã xảy ra lỗi từ server');
        } catch (e) {
          throw (response.body.isNotEmpty ? response.body : 'Đã xảy ra lỗi');
        }
      }

      final responseData = json.decode(response.body);

      _token = responseData['token'];
      _role = responseData['user']['role'];
      _userId = responseData['user']['id'];
      _email = responseData['user']['email'];

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', _token!);
      prefs.setString('role', _role!);
      prefs.setString('userId', _userId!);
      prefs.setString('email', _email!);

    } catch (error) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'auth/login');
  }

  Future<void> register(String email, String password) async {
    return _authenticate(email, password, 'auth/register');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false;
    }
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _userId = prefs.getString('userId');
    _email = prefs.getString('email');
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _userId = null;
    _email = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}