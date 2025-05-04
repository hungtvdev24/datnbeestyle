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
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại.';
      } else if (e.toString().contains('Đơn hàng không đạt giá trị tối thiểu')) {
        errorMessage = e.toString().split('Exception: ')[1];
      } else {
        errorMessage = 'Đã xảy ra lỗi: $e';
      }
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

      qrCode = response['qr_code'];
      if (qrCode == null || qrCode!.isEmpty) {
        throw Exception('Không nhận được URL thanh toán từ server');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và thử lại.';
      } else if (e.toString().contains('Đơn hàng không đạt giá trị tối thiểu')) {
        errorMessage = e.toString().split('Exception: ')[1];
      } else {
        errorMessage = 'Đã xảy ra lỗi: $e';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}