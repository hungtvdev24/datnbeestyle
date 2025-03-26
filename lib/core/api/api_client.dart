import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "https://72f7-104-28-254-73.ngrok-free.app/api";

  // Phương thức POST
  static Future<Map<String, dynamic>> postData(String url, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
      };
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.post(
        Uri.parse("$baseUrl/$url"),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('POST Request URL: $baseUrl/$url');
      print('Request data: $data');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody["message"] ?? "Yêu cầu không hợp lệ.");
      } else if (response.statusCode == 500) {
        throw Exception("Lỗi server: ${response.statusCode} - ${response.body}");
      } else {
        throw Exception("Lỗi không xác định: ${response.statusCode} - ${response.body}");
      }
    } on TimeoutException {
      throw Exception("Kết nối đến server quá lâu. Vui lòng thử lại.");
    } on FormatException {
      throw Exception("Dữ liệu từ server không đúng định dạng.");
    } on http.ClientException {
      throw Exception("Không thể kết nối đến server. Kiểm tra API hoặc mạng.");
    } catch (e) {
      throw Exception("Đã xảy ra lỗi không xác định: $e");
    }
  }

  // Phương thức GET
  static Future<dynamic> getData(String url, {String? token}) async {
    try {
      final headers = {
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
      };
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.get(
        Uri.parse("$baseUrl/$url"),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('GET Request URL: $baseUrl/$url');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 404) {
        throw Exception("Không tìm thấy dữ liệu: ${response.statusCode}");
      } else if (response.statusCode == 500) {
        throw Exception("Lỗi server: ${response.statusCode} - ${response.body}");
      } else {
        throw Exception('Failed to load data: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception("Kết nối đến server quá lâu. Vui lòng thử lại.");
    } on FormatException {
      throw Exception("Dữ liệu từ server không đúng định dạng.");
    } on http.ClientException {
      throw Exception("Không thể kết nối đến server. Kiểm tra API hoặc mạng.");
    } catch (e) {
      throw Exception("Đã xảy ra lỗi không xác định: $e");
    }
  }

  // Phương thức PUT
  static Future<Map<String, dynamic>> putData(String url, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
      };
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.put(
        Uri.parse("$baseUrl/$url"),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('PUT Request URL: $baseUrl/$url');
      print('Request data: $data');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody["message"] ?? "Yêu cầu không hợp lệ.");
      } else if (response.statusCode == 500) {
        throw Exception("Lỗi server: ${response.statusCode} - ${response.body}");
      } else {
        throw Exception("Lỗi không xác định: ${response.statusCode} - ${response.body}");
      }
    } on TimeoutException {
      throw Exception("Kết nối đến server quá lâu. Vui lòng thử lại.");
    } on FormatException {
      throw Exception("Dữ liệu từ server không đúng định dạng.");
    } on http.ClientException {
      throw Exception("Không thể kết nối đến server. Kiểm tra API hoặc mạng.");
    } catch (e) {
      throw Exception("Đã xảy ra lỗi không xác định: $e");
    }
  }

  // Phương thức DELETE
  static Future<Map<String, dynamic>> deleteData(String url, {String? token}) async {
    try {
      final headers = {
        "Accept": "application/json",
        "ngrok-skip-browser-warning": "true",
      };
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/$url"),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('DELETE Request URL: $baseUrl/$url');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {"message": "Xóa thành công"};
      } else if (response.statusCode == 401) {
        throw Exception("Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.");
      } else if (response.statusCode == 404) {
        throw Exception("Không tìm thấy dữ liệu để xóa: ${response.statusCode}");
      } else if (response.statusCode == 500) {
        throw Exception("Lỗi server: ${response.statusCode} - ${response.body}");
      } else {
        throw Exception("Lỗi không xác định: ${response.statusCode} - ${response.body}");
      }
    } on TimeoutException {
      throw Exception("Kết nối đến server quá lâu. Vui lòng thử lại.");
    } on FormatException {
      throw Exception("Dữ liệu từ server không đúng định dạng.");
    } on http.ClientException {
      throw Exception("Không thể kết nối đến server. Kiểm tra API hoặc mạng.");
    } catch (e) {
      throw Exception("Đã xảy ra lỗi không xác định: $e");
    }
  }
}