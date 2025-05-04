import '../../core/api/api_client.dart';
import '../../core/models/voucher.dart';

class VoucherService {
  static Future<List<Voucher>> getVouchers(String token) async {
    try {
      final response = await ApiClient.getData('vouchers', token: token);
      print('Raw response in VoucherService: $response'); // Log để kiểm tra dữ liệu gốc
      if (response is List) {
        final vouchers = response.map((item) => Voucher.fromJson(item as Map<String, dynamic>)).toList();
        print('Parsed vouchers in VoucherService: $vouchers'); // Log để kiểm tra dữ liệu đã parse
        return vouchers;
      } else {
        print('Response is not a list: $response');
        return [];
      }
    } catch (e) {
      print('Error in VoucherService: $e'); // Log lỗi
      throw Exception('Failed to fetch vouchers: $e');
    }
  }
}