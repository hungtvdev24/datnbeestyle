import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = "https://88a8-42-114-39-2.ngrok-free.app/api";
  static const String storageUrl = "https://88a8-42-114-39-2.ngrok-free.app/storage";

  // Lấy token từ SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('Retrieved token: $token');
    return token;
  }

  // Lưu token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('Saved token: $token');
  }

  // Xóa token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    print('Cleared token and user_id');
  }

  // Gửi yêu cầu POST
  static Future<Map<String, dynamic>> postData(
      String endpoint,
      Map<String, dynamic> data, {
        String? token,
        bool skipAuth = false,
      }) async {
    try {
      if (!skipAuth) {
        token ??= await getToken();
        if (token == null) {
          throw Exception("Không tìm thấy token. Vui lòng đăng nhập lại.");
        }
      }
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
      };
      if (!skipAuth && token != null) {
        headers["Authorization"] = "Bearer $token";
      }
      final url = endpoint.startsWith('http') ? endpoint : "$baseUrl/$endpoint";
      print('POST request to: $url with data: $data');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      print('Response: status=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 403) {
        throw Exception("Không có quyền truy cập. Vui lòng kiểm tra thông tin người dùng.");
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Dữ liệu không hợp lệ: ${errorBody["errors"] ?? response.body}');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Lỗi ${response.statusCode}: ${errorBody["error"] ?? response.body}');
      }
    } catch (e) {
      print('Error in postData: $e');
      rethrow;
    }
  }

  // Gửi yêu cầu GET
  static Future<dynamic> getData(String endpoint, {String? token}) async {
    try {
      token ??= await getToken();
      if (token == null) {
        throw Exception("Không tìm thấy token. Vui lòng đăng nhập lại.");
      }
      final headers = {
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
        "Authorization": "Bearer $token",
      };
      final url = endpoint.startsWith('http') ? endpoint : "$baseUrl/$endpoint";
      print('GET request to: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      print('Response: status=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 403) {
        throw Exception("Không có quyền truy cập. Vui lòng kiểm tra thông tin người dùng.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Lỗi ${response.statusCode}: ${errorBody["error"] ?? response.body}');
      }
    } catch (e) {
      print('Error in getData: $e');
      rethrow;
    }
  }

  // Gửi yêu cầu PUT
  static Future<Map<String, dynamic>> putData(
      String endpoint,
      Map<String, dynamic> data, {
        String? token,
      }) async {
    try {
      token ??= await getToken();
      if (token == null) {
        throw Exception("Không tìm thấy token. Vui lòng đăng nhập lại.");
      }
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
        "Authorization": "Bearer $token",
      };
      final url = endpoint.startsWith('http') ? endpoint : "$baseUrl/$endpoint";
      print('PUT request to: $url with data: $data');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      print('Response: status=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 403) {
        throw Exception("Không có quyền truy cập. Vui lòng kiểm tra thông tin người dùng.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Lỗi ${response.statusCode}: ${errorBody["error"] ?? response.body}');
      }
    } catch (e) {
      print('Error in putData: $e');
      rethrow;
    }
  }

  // Gửi yêu cầu DELETE
  static Future<Map<String, dynamic>> deleteData(String endpoint, {String? token}) async {
    try {
      token ??= await getToken();
      if (token == null) {
        throw Exception("Không tìm thấy token. Vui lòng đăng nhập lại.");
      }
      final headers = {
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
        "Authorization": "Bearer $token",
      };
      final url = endpoint.startsWith('http') ? endpoint : "$baseUrl/$endpoint";
      print('DELETE request to: $url');
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      print('Response: status=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        return {"message": "Xóa thành công"};
      } else if (response.statusCode == 401) {
        throw Exception("Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 403) {
        throw Exception("Không có quyền truy cập. Vui lòng kiểm tra thông tin người dùng.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Lỗi ${response.statusCode}: ${errorBody["error"] ?? response.body}');
      }
    } catch (e) {
      print('Error in deleteData: $e');
      rethrow;
    }
  }

  // Gửi tin nhắn
  static Future<Map<String, dynamic>> sendMessage(
      int receiverId,
      String content, {
        String receiverType = 'App\\Models\\User',
      }) async {
    return await postData('messages', {
      'receiver_id': receiverId,
      'receiver_type': receiverType,
      'content': content,
    });
  }

  // Lấy danh sách tin nhắn
  static Future<List<dynamic>> getMessages(
      int receiverId, {
        String receiverType = 'App\\Models\\User',
      }) async {
    final uri = Uri.parse("$baseUrl/messages/$receiverId")
        .replace(queryParameters: {'receiver_type': receiverType});
    final response = await getData(uri.toString());
    return response['data'];
  }

  // Đánh dấu tin nhắn đã đọc
  static Future<Map<String, dynamic>> markMessageAsRead(int messageId) async {
    return await postData('messages/$messageId/read', {});
  }

  // Lấy danh sách thông báo
  static Future<List<dynamic>> getNotifications(int userId) async {
    final uri = Uri.parse("$baseUrl/notifications?user_id=$userId");
    final response = await getData(uri.toString());
    return response['data'];
  }

  // Đánh dấu thông báo đã đọc
  static Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    return await postData('notifications/$notificationId/read', {});
  }

  // Lấy danh sách người dùng
  static Future<List<dynamic>> getUsers() async {
    final response = await getData('users');
    return response['users'];
  }

  // Lấy thông tin người dùng hiện tại
  static Future<Map<String, dynamic>> getUser() async {
    final response = await getData('user');
    return response['user'];
  }

  // Lấy danh sách admin
  static Future<List<dynamic>> getAdmins() async {
    final response = await getData('admins');
    return response['admins'];
  }

  // Lấy URL hình ảnh
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty || imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$storageUrl/$imagePath';
  }
}