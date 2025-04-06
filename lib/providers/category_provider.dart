import 'package:flutter/foundation.dart';
import '../../core/api/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<dynamic> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _hasError = false;
    notifyListeners();

    try {
      final fetchedCategories = await _categoryService.fetchCategories();
      _categories = fetchedCategories;
      if (_categories.isEmpty) {
        _errorMessage = "Không có danh mục nào được tìm thấy.";
      }
      print('Fetched categories in CategoryProvider: $_categories');
    } catch (e) {
      _errorMessage = "Lỗi khi tải danh mục: $e";
      _hasError = true;
      _categories = [];
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshCategories() async {
    await loadCategories();
  }
}