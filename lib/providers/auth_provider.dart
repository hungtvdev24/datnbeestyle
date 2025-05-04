import 'package:flutter/material.dart';
import '../core/api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Thử đăng nhập: email=$email, password=$password');
      final response = await ApiClient.postData(
        'login',
        {
          'email': email,
          'password': password,
        },
        skipAuth: true, // Không yêu cầu token cho login
      );
      print('Phản hồi đăng nhập: $response');

      if (response.containsKey('token') && response.containsKey('user') && response['user']['id'] != null) {
        _token = response['token'] as String;
        await ApiClient.saveToken(_token!); // Lưu token vào SharedPreferences
        await ApiClient.saveToken(_token!); // Lưu lại để đảm bảo
        _errorMessage = null;
        print('Đăng nhập thành công, Token: $_token');
        await fetchUserData();
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.containsKey('error')) {
        _errorMessage = response['error'] as String;
        print('Đăng nhập thất bại: $_errorMessage');
      } else {
        _errorMessage = 'Đăng nhập thất bại. Vui lòng kiểm tra lại.';
        print('Đăng nhập thất bại: Phản hồi không mong đợi - $response');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Lỗi khi đăng nhập: $e";
      _isLoading = false;
      print('Lỗi đăng nhập: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Thử đăng ký: name=$name, email=$email, phone=$phone, password=$password');
      final response = await ApiClient.postData(
        'register',
        {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
        skipAuth: true, // Không yêu cầu token cho register
      );
      print('Phản hồi đăng ký: $response');

      if (response.containsKey('token') && response.containsKey('user') && response['user']['id'] != null) {
        _token = response['token'] as String;
        await ApiClient.saveToken(_token!); // Lưu token vào SharedPreferences
        _errorMessage = null;
        print('Đăng ký thành công, Token: $_token');
        await fetchUserData();
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.containsKey('error')) {
        _errorMessage = response['error'] as String;
        print('Đăng ký thất bại: $_errorMessage');
      } else {
        _errorMessage = 'Đăng ký thất bại. Vui lòng kiểm tra lại.';
        print('Đăng ký thất bại: Phản hồi không mong đợi - $response');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Lỗi khi đăng ký: $e";
      _isLoading = false;
      print('Lỗi đăng ký: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.getData('user');
      print('Phản hồi lấy dữ liệu người dùng: $response');
      if (response.containsKey('user') && response['user']['id'] != null) {
        _userData = response['user'];
        _errorMessage = null;
        print('Lấy dữ liệu người dùng thành công: $_userData');
      } else {
        _errorMessage = 'Không thể lấy thông tin người dùng.';
        print('Lấy dữ liệu người dùng thất bại: $response');
      }
    } catch (e) {
      _errorMessage = "Lỗi khi lấy thông tin người dùng: $e";
      print('Lỗi lấy dữ liệu người dùng: $_errorMessage');
    }



    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    try {
      await ApiClient.clearToken();
      _token = null;
      _userData = null;
      _errorMessage = null;
      print('Đăng xuất thành công');
      notifyListeners();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _errorMessage = "Lỗi khi đăng xuất: $e";
      print('Lỗi đăng xuất: $_errorMessage');
      notifyListeners();
    }
  }
}