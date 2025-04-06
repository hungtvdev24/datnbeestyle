import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ReviewService {
  static Future<Map<String, dynamic>> submitReview(
      String token,
      int orderId,
      int productId,
      int rating,
      String? comment,
      String? imageUrl,
      ) async {
    final data = {
      'id_donHang': orderId,
      'id_sanPham': productId,
      'soSao': rating,
      if (comment != null && comment.isNotEmpty) 'binhLuan': comment,
      if (imageUrl != null && imageUrl.isNotEmpty) 'urlHinhAnh': imageUrl,
    };

    return await ApiClient.postData('reviews', data, token: token);
  }
}