import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  Map<String, dynamic>? _errorMessage; // Thay đổi để lưu lỗi dưới dạng Map
  String? _token;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get errorMessage => _errorMessage; // Trả về Map thay vì String
  String? get token => _token;

  UserProvider() {
    _loadToken();
  }

  // Tải token từ SharedPreferences
  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      fetchUserData();
    }
    notifyListeners();
  }

  // Lưu token sau khi đăng nhập
  Future<void> setToken(String token) async {
    _token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    fetchUserData();
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    if (_token == null) {
      _errorMessage = {"general": "Chưa đăng nhập. Vui lòng đăng nhập."};
      _userData = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.getData('user', token: _token);
      print('User Data Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('error')) {
        _errorMessage = response['error'] is String
            ? {"general": response['error']}
            : response['error'];
        _userData = null;
      } else {
        _userData = response['user']; // Lấy dữ liệu từ key 'user'
      }
    } catch (e) {
      _errorMessage = {"general": "Lỗi khi tải thông tin người dùng: $e"};
      _userData = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUser(Map<String, dynamic> updatedData) async {
    if (_token == null) {
      _errorMessage = {"general": "Chưa đăng nhập. Vui lòng đăng nhập."};
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.putData('user/update', updatedData, token: _token);
      print('Update User Response: $response');

      if (response.containsKey('error')) {
        _errorMessage = response['error'] is String
            ? {"general": response['error']}
            : response['error'];
      } else {
        _userData = response['user']; // Cập nhật dữ liệu người dùng
        _errorMessage = null; // Xóa lỗi nếu cập nhật thành công
      }
    } catch (e) {
      _errorMessage = {"general": "Lỗi khi cập nhật thông tin người dùng: $e"};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    try {
      await ApiClient.postData('logout', {}, token: _token);
    } catch (e) {
      print('Error during logout: $e');
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _userData = null;
    _token = null;
    notifyListeners();
    Navigator.pushReplacementNamed(context, '/login');
  }
}