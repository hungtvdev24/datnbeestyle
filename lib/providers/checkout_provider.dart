import 'package:flutter/material.dart';
import '../core/api/checkout_service.dart';

class CheckoutProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? orderData;

  Future<void> placeOrder({
    required String token,
    required int idDiaChi,
    required String phuongThucThanhToan,
    required List<Map<String, dynamic>> selectedItems,
    String? message,
  }) async {
    isLoading = true;
    errorMessage = null;
    orderData = null;
    notifyListeners();

    try {
      final response = await CheckoutService.placeOrder(
        token: token,
        idDiaChi: idDiaChi,
        phuongThucThanhToan: phuongThucThanhToan,
        selectedItems: selectedItems,
        message: message,
      );

      if (response.containsKey('error')) {
        errorMessage = response['error'];
      } else {
        orderData = response;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}