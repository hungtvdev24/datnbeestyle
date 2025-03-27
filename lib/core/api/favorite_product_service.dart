import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class FavoriteProductService {
  static const String baseUrl = 'https://72f7-104-28-254-73.ngrok-free.app/api'; // Cập nhật URL ngrok

  /// Lấy danh sách sản phẩm yêu thích của người dùng.
  static Future<List<dynamic>> getFavoriteProducts(String token) async {
    try {
      final response = await ApiClient.getData('favorite', token: token);
      // Giả sử API trả về dạng { "favorites": [ ... ] } hoặc trực tiếp List
      if (response is Map<String, dynamic> && response.containsKey('favorites')) {
        return response['favorites'] as List<dynamic>;
      } else if (response is List) {
        return response;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Lỗi khi tải sản phẩm yêu thích: $e');
    }
  }

  /// Thêm một sản phẩm vào danh sách yêu thích.
  static Future<Map<String, dynamic>> addFavoriteProduct(String token, int productId) async {
    try {
      final response = await ApiClient.postData(
        'favorite/add/$productId',
        {},
        token: token,
      );
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      return response;
    } catch (e) {
      throw Exception('Lỗi khi thêm sản phẩm yêu thích: $e');
    }
  }

  /// Xóa một sản phẩm khỏi danh sách yêu thích.
  static Future<Map<String, dynamic>> removeFavoriteProduct(String token, int productId) async {
    try {
      final response = await ApiClient.postData(
        'favorite/remove/$productId',
        {},
        token: token,
      );
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      return response;
    } catch (e) {
      throw Exception('Lỗi khi xóa sản phẩm yêu thích: $e');
    }
  }
}