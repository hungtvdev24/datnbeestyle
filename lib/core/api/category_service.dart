import 'dart:convert';
import '../../core/api/api_client.dart';

class CategoryService {
  static const String endpoint = 'categories';

  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await ApiClient.getData(endpoint);
      print('Raw Response from CategoryService: $response');

      if (response is List) {
        print('Categories Data: $response');
        return response;
      } else if (response is Map && response.containsKey('error')) {
        print('API Error: ${response['error']}');
        throw Exception('API Error: ${response['error']}');
      } else {
        print('Unexpected response format: $response');
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('Error in fetchCategories: $e');
      throw Exception('Error fetching categories: $e');
    }
  }
}