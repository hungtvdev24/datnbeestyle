import 'package:flutter/material.dart';
import '../core/api/checkout_service.dart';

class CheckoutProvider with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? orderData;
  String? qrCode;

  Future<void> placeOrder({
    required String token,
    required int idDiaChi,
    required String phuongThucThanhToan,
    required List<Map<String, dynamic>> selectedItems,
    String? message,
    String? voucherCode,
  }) async {
    isLoading = true;
    errorMessage = null;
    orderData = null;
    qrCode = null;
    notifyListeners();

    try {
      final response = await CheckoutService.placeOrder(
        token: token,
        idDiaChi: idDiaChi,
        phuongThucThanhToan: phuongThucThanhToan,
        selectedItems: selectedItems,
        message: message,
        voucherCode: voucherCode,
      );

      orderData = response['donHang'];
      qrCode = response['qr_code'];
    } catch (e) {
      errorMessage = _handleError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getVNPayPaymentUrl({
    required String token,
    required int idDiaChi,
    required String phuongThucThanhToan,
    required List<Map<String, dynamic>> selectedItems,
    String? message,
    String? voucherCode,
    required double totalAmount,
  }) async {
    isLoading = true;
    errorMessage = null;
    qrCode = null;
    orderData = null;
    notifyListeners();

    try {
      final response = await CheckoutService.placeOrder(
        token: token,
        idDiaChi: idDiaChi,
        phuongThucThanhToan: phuongThucThanhToan,
        selectedItems: selectedItems,
        message: message,
        voucherCode: voucherCode,
        totalAmount: totalAmount,
      );

      qrCode = response['qr_code'];
      orderData = response['donHang'];
      if (phuongThucThanhToan == 'VN_PAY' && (qrCode == null || qrCode!.isEmpty)) {
        throw Exception('Không nhận được URL thanh toán từ server');
      }
    } catch (e) {
      errorMessage = _handleError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _handleError(dynamic e) {
    if (e.toString().contains('401')) {
      return 'Token không hợp lệ hoặc đã hết hạn. Vui lòng đăng nhập lại.';
    } else if (e.toString().contains('403')) {
      return 'Không có quyền truy cập. Vui lòng kiểm tra thông tin người dùng.';
    } else if (e.toString().contains('TimeoutException')) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại.';
    } else if (e.toString().contains('Đơn hàng không đạt giá trị tối thiểu')) {
      return e.toString().split('Exception: ')[1];
    } else {
      return 'Lỗi: $e';
    }
  }
}