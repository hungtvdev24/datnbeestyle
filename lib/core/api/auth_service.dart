import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "https://6a67-42-117-88-252.ngrok-free.app/api";
  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _postData('login', {"email": email, "password": password});
    if (response.containsKey('token')) {
      // Lưu token sau khi đăng nhập thành công
      await saveToken(response['token']);
    }
    return response;
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    final response = await _postData('register', {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
    });
    if (response.containsKey('token')) {
      // Lưu token sau khi đăng ký thành công (nếu API trả về token)
      await saveToken(response['token']);
    }
    return response;
  }

  Future<Map<String, dynamic>> _postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      print('POST $endpoint Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        return {"error": responseData["message"] ?? "Lỗi không xác định"};
      }
    } catch (e) {
      return {"error": "Không thể kết nối đến server. Kiểm tra mạng hoặc API: $e"};
    }
  }

  // Lưu token vào shared_preferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Lấy token từ shared_preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Xóa token (khi đăng xuất)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}