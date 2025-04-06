import 'dart:convert';
import '../../core/api/api_client.dart';

class ProductService {

  static const String popularEndpoint = 'products/popular-public';
  static const String searchEndpoint = 'search';

  // Lấy danh sách sản phẩm phổ biến (công khai, không cần token)
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await ApiClient.getData(popularEndpoint, token: null);
      print('Raw Response from ProductService (fetchProducts): $response');

      if (response is List) {
        print('Data is List: $response');
        return response;
      } else if (response is Map && response.containsKey('message')) {
        print('No products found: ${response['message']}');
        return [];
      } else if (response is Map && response.containsKey('error')) {
        print('API Error: ${response['error']}');
        throw Exception('API Error: ${response['error']}');
      } else {
        print('Unexpected response format: $response');
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('Error in fetchProducts: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  // Tìm kiếm sản phẩm theo query (công khai, không cần token)
  Future<List<dynamic>> searchProducts(String query) async {
    try {
      final response = await ApiClient.getData('$searchEndpoint?query=$query', token: null);
      print('Raw Response from ProductService (searchProducts): $response');

      if (response is Map && response.containsKey('products')) {
        print('Search Data: ${response['products']}');
        return response['products'] as List<dynamic>;
      } else if (response is Map && response.containsKey('error')) {
        print('API Error: ${response['error']}');
        throw Exception('API Error: ${response['error']}');
      } else {
        print('Unexpected response format: $response');
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('Error in searchProducts: $e');
      throw Exception('Error searching products: $e');
    }
  }

  // Lấy danh sách đánh giá của sản phẩm (công khai, không cần token)
  Future<List<dynamic>> fetchReviews(int productId) async {
    try {
      final response = await ApiClient.getData('products/$productId/reviews', token: null);
      print('Raw Response from ProductService (fetchReviews): $response');

      if (response is Map && response.containsKey('reviews')) {
        print('Reviews Data: ${response['reviews']}');
        return response['reviews'] as List<dynamic>;
      } else if (response is Map && response.containsKey('message')) {
        print('No reviews found: ${response['message']}');
        return [];
      } else if (response is Map && response.containsKey('error')) {
        print('API Error: ${response['error']}');
        throw Exception('API Error: ${response['error']}');
      } else {
        print('Unexpected response format: $response');
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('Error in fetchReviews: $e');
      throw Exception('Error fetching reviews: $e');
    }
  }
}