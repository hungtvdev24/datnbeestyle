import 'dart:async';
import 'api_client.dart';

class MyOrderService {
  /// Lấy danh sách đơn hàng của người dùng.
  static Future<List<dynamic>> getMyOrders(String token) async {
    try {
      final response = await ApiClient.getData('orders', token: token);
      // API hiện trả về dạng { "orders": [ ... ] }
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
      // Giả sử endpoint hủy đơn hàng là POST orders/{orderId}/cancel
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
}