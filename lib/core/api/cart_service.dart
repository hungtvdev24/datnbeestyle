import 'dart:convert';
import '../api/api_client.dart';

class CartService {
  /// Lấy giỏ hàng từ API
  static Future<Map<String, dynamic>> getCart(String token) async {
    try {
      final response = await ApiClient.getData('cart', token: token);
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Lỗi khi tải giỏ hàng: $e');
    }
  }

  /// Cập nhật số lượng của mục giỏ hàng
  static Future<Map<String, dynamic>> updateCartItemQuantity(String token, int idMucGioHang, int soLuong) async {
    if (soLuong < 1) throw Exception('Số lượng phải >= 1');
    try {
      final response = await ApiClient.postData(
        'cart/update/$idMucGioHang',
        {"soLuong": soLuong},
        token: token,
      );
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      return response;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật số lượng: $e');
    }
  }

  /// Xoá một mục khỏi giỏ hàng
  static Future<Map<String, dynamic>> removeCartItem(String token, int idMucGioHang) async {
    try {
      final response = await ApiClient.postData(
        'cart/remove/$idMucGioHang',
        {},
        token: token,
      );
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      return response;
    } catch (e) {
      throw Exception('Lỗi khi xóa mục giỏ hàng: $e');
    }
  }

  /// Thêm sản phẩm vào giỏ hàng với variation_id
  static Future<Map<String, dynamic>> addToCart(String token, int productId, int quantity, int variationId) async {
    try {
      final response = await ApiClient.postData(
        'cart/add/$productId', // Điều chỉnh endpoint theo backend
        {
          "soLuong": quantity,
          "variation_id": variationId,
        },
        token: token,
      );
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      return response;
    } catch (e) {
      throw Exception('Lỗi khi thêm sản phẩm vào giỏ hàng: $e');
    }
  }
}