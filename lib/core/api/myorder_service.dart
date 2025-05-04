import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class MyOrderService {
  /// Lấy danh sách đơn hàng của người dùng.
  static Future<List<dynamic>> getMyOrders(String token) async {
    try {
      final response = await ApiClient.getData('orders', token: token);
      if (response is Map<String, dynamic> && response.containsKey('orders')) {
        return response['orders'] as List<dynamic>;
      } else if (response is List) {
        return response;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách đơn hàng: $e');
    }
  }

  /// Lấy chi tiết một đơn hàng.
  static Future<Map<String, dynamic>> getOrderDetail(String token, int orderId) async {
    try {
      final response = await ApiClient.getData('orders/$orderId', token: token);
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết đơn hàng: $e');
    }
  }

  /// Hủy đơn hàng nếu đơn hàng ở trạng thái "cho_xac_nhan".
  static Future<Map<String, dynamic>> cancelOrder(String token, int orderId) async {
    try {
      final response = await ApiClient.postData(
        'orders/$orderId/cancel',
        {},
        token: token,
      );
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      return response;
    } catch (e) {
      throw Exception('Lỗi khi hủy đơn hàng: $e');
    }
  }

  /// Kiểm tra xem một sản phẩm trong đơn hàng đã được đánh giá hay chưa.
  static Future<bool> hasReviewedProduct(String token, int orderId, int productId, int variationId) async {
    try {
      final response = await ApiClient.getData(
        'orders/$orderId/reviews/$productId/$variationId',
        token: token,
      );
      // Giả định API trả về một trường 'hasReviewed' để xác định trạng thái
      return response['hasReviewed'] ?? false;
    } catch (e) {
      print('Error checking review status: $e');
      return false; // Trả về false nếu có lỗi
    }
  }
}