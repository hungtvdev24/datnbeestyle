import 'package:flutter/material.dart';
import '../core/api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Login attempt: email=$email, password=$password');
      final response = await ApiClient.postData('login', {
        'email': email,
        'password': password,
      });

      print('Login response: $response');
      if (response.containsKey('token')) {
        _token = response['token'] as String;
        _errorMessage = null;
        print('Login successful, Token: $_token');
      } else if (response.containsKey('error')) {
        _errorMessage = response['error'] as String;
        print('Login failed: $_errorMessage');
      } else {
        _errorMessage = 'Đăng nhập thất bại. Vui lòng kiểm tra lại.';
        print('Login failed: Unexpected response - $response');
      }
      _isLoading = false;
      notifyListeners();
      return _token != null;
    } catch (e) {
      _errorMessage = "Lỗi khi đăng nhập: $e";
      _isLoading = false;
      print('Login error: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Register attempt: name=$name, email=$email, phone=$phone, password=$password');
      final response = await ApiClient.postData('register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      print('Register response: $response');
      if (response.containsKey('message') && response['message'] == 'Đăng ký thành công') {
        _errorMessage = null;
        print('Register successful');
      } else if (response.containsKey('error')) {
        _errorMessage = response['error'] as String;
        print('Register failed: $_errorMessage');
      } else {
        _errorMessage = 'Đăng ký thất bại. Vui lòng kiểm tra lại.';
        print('Register failed: Unexpected response - $response');
      }
      _isLoading = false;
      notifyListeners();
      return _errorMessage == null;
    } catch (e) {
      _errorMessage = "Lỗi khi đăng ký: $e";
      _isLoading = false;
      print('Register error: $_errorMessage');
      notifyListeners();
      return false;
    }
  }
}