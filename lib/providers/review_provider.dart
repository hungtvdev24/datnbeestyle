import 'package:flutter/material.dart';
import '../core/api/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> submitReview(
      String token,
      int orderId,
      int productId,
      int rating,
      String? comment,
      String? imageUrl,
      ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ReviewService.submitReview(token, orderId, productId, rating, comment, imageUrl);
      if (response.containsKey('message') && response['message'] == 'Đánh giá đã được gửi thành công!') {
        return true;
      } else {
        errorMessage = response['message'] ?? 'Lỗi không xác định';
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}