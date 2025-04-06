import 'package:flutter/material.dart';
import '../core/api/favorite_product_service.dart';

class FavoriteProductProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setFavorites(List<Map<String, dynamic>> items) {
    _favorites = items;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Tải danh sách sản phẩm yêu thích từ API.
  Future<void> loadFavoriteProducts(String token) async {
    setLoading(true);
    setErrorMessage(null);
    try {
      final data = await FavoriteProductService.getFavoriteProducts(token);
      setFavorites(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      final error = e.toString();
      if (error.contains('404')) {
        setErrorMessage('404'); // Dùng để hiển thị "Chưa có sản phẩm nào"
      } else {
        setErrorMessage('Không thể tải sản phẩm yêu thích: $error');
      }
    } finally {
      setLoading(false);
    }
  }

  /// Thêm sản phẩm vào danh sách yêu thích.
  Future<void> addFavoriteProduct(String token, int productId) async {
    setLoading(true);
    setErrorMessage(null);
    try {
      await FavoriteProductService.addFavoriteProduct(token, productId);
      await loadFavoriteProducts(token); // Tải lại danh sách sau khi thêm
    } catch (e) {
      setErrorMessage('Không thể thêm sản phẩm yêu thích: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Xóa sản phẩm khỏi danh sách yêu thích.
  Future<void> removeFavoriteProduct(String token, int productId) async {
    setLoading(true);
    setErrorMessage(null);
    try {
      await FavoriteProductService.removeFavoriteProduct(token, productId);
      await loadFavoriteProducts(token); // Tải lại danh sách sau khi xóa
    } catch (e) {
      setErrorMessage('Không thể xóa sản phẩm yêu thích: $e');
    } finally {
      setLoading(false);
    }
  }
}