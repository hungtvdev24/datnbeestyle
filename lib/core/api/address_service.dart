import '../../core/api/api_client.dart';
import '../../core/models/address.dart';

class AddressService {
  // Lấy danh sách địa chỉ
  static Future<List<Address>> getAddresses(String token) async {
    try {
      final response = await ApiClient.getData('addresses', token: token);
      return (response as List).map((item) => Address.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  // Tạo mới địa chỉ
  static Future<Address?> createAddress(String token, Address address) async {
    try {
      final response = await ApiClient.postData('addresses', address.toJson(), token: token);
      if (response is Map && response['data'] != null) {
        return Address.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create address: $e');
    }
  }

  // Cập nhật địa chỉ
  static Future<Address?> updateAddress(String token, Address address) async {
    try {
      final response = await ApiClient.putData(
        'addresses/${address.idDiaChi}',
        address.toJson(),
        token: token,
      );
      if (response is Map && response['data'] != null) {
        return Address.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  // Xóa địa chỉ
  static Future<void> removeAddress(String token, int idDiaChi) async {
    try {
      await ApiClient.deleteData('addresses/$idDiaChi', token: token);
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }
}