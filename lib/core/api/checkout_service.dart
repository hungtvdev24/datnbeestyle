import '../api/api_client.dart';

class CheckoutService {
  static Future<Map<String, dynamic>> placeOrder({
    required String token,
    required int idDiaChi,
    required String phuongThucThanhToan,
    required List<Map<String, dynamic>> selectedItems,
    String? message,
  }) async {
    try {
      final data = {
        'id_diaChi': idDiaChi,
        'phuongThucThanhToan': phuongThucThanhToan,
        'items': selectedItems.map((item) {
          return {
            'id_mucGioHang': item['id_mucGioHang'],
            'id_sanPham': item['id_sanPham'],
            'soLuong': item['soLuong'],
          };
        }).toList(),
        'message': message ?? '',
      };

      final response = await ApiClient.postData(
        'checkout',
        data,
        token: token,
      );

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      return response;
    } catch (e) {
      throw Exception('Lỗi khi đặt hàng (checkout): $e');
    }
  }
}