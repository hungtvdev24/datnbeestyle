import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Lấy token từ SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('Get token: $token');
    return token;
  }

  // Lấy userId từ SharedPreferences
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    print('Get userId: $userId');
    return userId;
  }

  // Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Thử đăng nhập: email=$email, password=$password');
    try {
      final response = await http.post(
        Uri.parse('https://88a8-42-114-39-2.ngrok-free.app/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Login response: status=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login data: $data');
        if (data['token'] != null && data['user'] != null && data['user']['id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          await prefs.setInt('user_id', data['user']['id']);
          print('Token saved: ${data['token']}');
          print('User ID saved: ${data['user']['id']}');
          final savedUserId = await prefs.getInt('user_id');
          print('Verified saved userId: $savedUserId');
          return {
            'success': true,
            'token': data['token'],
            'userId': data['user']['id'],
            'user': data['user'],
          };
        } else {
          print('Missing token or user info in response');
          return {
            'success': false,
            'error': 'Không tìm thấy token hoặc thông tin người dùng trong phản hồi.',
            'token': null,
            'userId': null,
          };
        }
      } else if (response.statusCode == 401) {
        print('Invalid credentials');
        return {
          'success': false,
          'error': 'Email hoặc mật khẩu không đúng.',
          'token': null,
          'userId': null,
        };
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        print('Validation error: ${errorBody['errors']}');
        return {
          'success': false,
          'error': 'Dữ liệu không hợp lệ: ${errorBody['errors']}',
          'token': null,
          'userId': null,
        };
      } else {
        print('Server error: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Lỗi server: ${response.statusCode} - ${response.body}',
          'token': null,
          'userId': null,
        };
      }
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'token': null,
        'userId': null,
      };
    }
  }

  // Đăng ký
  Future<Map<String, dynamic>> register(String name, String email, String phone, String password, int tuoi) async {
    print('Thử đăng ký: name=$name, email=$email, phone=$phone, tuoi=$tuoi');
    try {
      final response = await http.post(
        Uri.parse('https://88a8-42-114-39-2.ngrok-free.app/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'tuoi': tuoi,
        }),
      ).timeout(const Duration(seconds: 30));
      print('Register response: status=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null && data['user'] != null && data['user']['id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          await prefs.setInt('user_id', data['user']['id']);
          print('Token saved: ${data['token']}');
          print('User ID saved: ${data['user']['id']}');
          final savedUserId = await prefs.getInt('user_id');
          print('Verified saved userId: $savedUserId');
          return {
            'success': true,
            'token': data['token'],
            'userId': data['user']['id'],
            'user': data['user'],
          };
        } else {
          print('Missing token or user info in response');
          return {
            'success': false,
            'error': 'Không tìm thấy token hoặc thông tin người dùng trong phản hồi.',
            'token': null,
            'userId': null,
          };
        }
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        print('Validation error: ${errorBody['errors']}');
        return {
          'success': false,
          'error': 'Dữ liệu không hợp lệ: ${errorBody['errors']}',
          'token': null,
          'userId': null,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        print('Registration error: ${errorBody['error']}');
        return {
          'success': false,
          'error': errorBody['error'] ?? 'Lỗi server: ${response.statusCode} - ${response.body}',
          'token': null,
          'userId': null,
        };
      }
    } catch (e) {
      print('Lỗi đăng ký: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'token': null,
        'userId': null,
      };
    }
  }

  // Lấy thông tin người dùng
  Future<Map<String, dynamic>> getUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
    }
    try {
      final response = await http.get(
        Uri.parse('https://88a8-42-114-39-2.ngrok-free.app/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(const Duration(seconds: 30));
      print('Get user response: status=${response.statusCode}, body=${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        throw Exception('Lỗi lấy thông tin người dùng: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getUser: $e');
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    final token = await getToken();
    if (token == null) {
      print('No token found for logout');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://88a8-42-114-39-2.ngrok-free.app/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(const Duration(seconds: 30));
      print('Logout request sent');
    } catch (e) {
      print('Lỗi đăng xuất: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      print('Token và userId đã được xóa');
    }
  }
}