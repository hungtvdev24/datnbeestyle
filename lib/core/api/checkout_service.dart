import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_client.dart';

class CheckoutService {
  static Future<Map<String, dynamic>> placeOrder({
    required String token,
    required int idDiaChi,
    required String phuongThucThanhToan,
    required List<Map<String, dynamic>> selectedItems,
    String? message,
    String? voucherCode,
    double? totalAmount,
  }) async {
    try {
      final data = {
        'id_diaChi': idDiaChi,
        'phuongThucThanhToan': phuongThucThanhToan,
        'items': selectedItems.map((item) {
          return {
            'id_mucGioHang': item['id_mucGioHang'],
            'id_sanPham': item['id_sanPham'],
            'variation_id': item['variation_id'],
            'soLuong': item['soLuong'],
          };
        }).toList(),
        'message': message ?? '',
        'voucher_code': voucherCode,
        if (phuongThucThanhToan == 'VN_PAY' && totalAmount != null)
          'total_amount': totalAmount,
      };

      final response = await ApiClient.postData('checkout', data, token: token);

      return {
        'message': response['message'] as String? ?? 'Đặt hàng thành công',
        'donHang': response['donHang'] as Map<String, dynamic>?,
        'qr_code': response['qr_code'] as String? ?? '',
      };
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (e.toString().contains('403')) {
        throw Exception('Không có quyền truy cập. Vui lòng kiểm tra thông tin người dùng.');
      } else {
        throw Exception('Lỗi khi đặt hàng: $e');
      }
    }
  }
}