import 'package:flutter/material.dart';
import '../core/api/myorder_service.dart';

class MyOrderProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<dynamic> orders = [];
  Map<String, dynamic>? orderDetail;

  Future<void> loadOrders(String token) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orders = await MyOrderService.getMyOrders(token);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderDetail(String token, int orderId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orderDetail = await MyOrderService.getOrderDetail(token, orderId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String token, int orderId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await MyOrderService.cancelOrder(token, orderId);
      // Sau khi hủy thành công, bạn có thể cập nhật lại danh sách đơn hàng nếu cần
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}