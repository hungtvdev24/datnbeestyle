import 'package:flutter/material.dart';
import '../../core/api/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<dynamic> _products = []; // Danh sách sản phẩm phổ biến
  List<dynamic> _suggestedProducts = []; // Danh sách sản phẩm gợi ý
  List<dynamic> _searchResults = []; // Danh sách kết quả tìm kiếm
  List<dynamic> _reviews = []; // Danh sách đánh giá
  bool _isLoading = false; // Trạng thái tải
  bool _isSearching = false; // Trạng thái đang tìm kiếm
  bool _isLoadingReviews = false; // Trạng thái tải đánh giá
  String? _errorMessage; // Thông báo lỗi
  String? _searchErrorMessage; // Thông báo lỗi tìm kiếm
  String? _reviewsErrorMessage; // Thông báo lỗi tải đánh giá
  bool _hasError = false; // Trạng thái có lỗi
  bool _hasSearchError = false; // Trạng thái có lỗi tìm kiếm
  bool _hasReviewsError = false; // Trạng thái có lỗi tải đánh giá

  List<dynamic> get products => _products;
  List<dynamic> get suggestedProducts => _suggestedProducts;
  List<dynamic> get searchResults => _searchResults;
  List<dynamic> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get errorMessage => _errorMessage;
  String? get searchErrorMessage => _searchErrorMessage;
  String? get reviewsErrorMessage => _reviewsErrorMessage;
  bool get hasError => _hasError;
  bool get hasSearchError => _hasSearchError;
  bool get hasReviewsError => _hasReviewsError;

  ProductProvider() {
    loadProducts();
  }

  // Tải danh sách sản phẩm phổ biến
  Future<void> loadProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _hasError = false;
    notifyListeners();

    try {
      final fetchedProducts = await _productService.fetchProducts();
      _products = fetchedProducts.map((product) {
        // Đảm bảo rằng sản phẩm có variations, nếu không thì thêm một variations mặc định
        if (product['variations'] == null || product['variations'].isEmpty) {
          return {
            ...product,
            'variations': [
              {
                'id': null,
                'color': 'Mặc định',
                'size': null,
                'price': product['gia'] ?? 0.0,
                'stock': 0,
                'images': [
                  {'image_url': 'https://picsum.photos/400/200'} // Hình ảnh mặc định
                ]
              }
            ]
          };
        }
        return product;
      }).toList();
      if (_products.isEmpty) {
        _errorMessage = "Không có sản phẩm nào được tìm thấy.";
      }
      print('Fetched products in ProductProvider: $_products');
    } catch (e) {
      _errorMessage = "Lỗi khi tải sản phẩm: $e";
      _hasError = true;
      _products = [];
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Tải danh sách đánh giá của sản phẩm
  Future<void> loadReviews(int productId) async {
    _isLoadingReviews = true;
    _reviewsErrorMessage = null;
    _hasReviewsError = false;
    notifyListeners();

    try {
      final fetchedReviews = await _productService.fetchReviews(productId);
      _reviews = fetchedReviews;
      if (_reviews.isEmpty) {
        _reviewsErrorMessage = "Chưa có đánh giá nào cho sản phẩm này.";
      }
      print('Fetched reviews in ProductProvider: $_reviews');
    } catch (e) {
      _reviewsErrorMessage = "Lỗi khi tải đánh giá: $e";
      _hasReviewsError = true;
      _reviews = [];
      print(_reviewsErrorMessage);
    }

    _isLoadingReviews = false;
    notifyListeners();
  }

  // Tìm kiếm sản phẩm
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchErrorMessage = null;
      _hasSearchError = false;
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = null;
    _hasSearchError = false;
    notifyListeners();

    try {
      final results = await _productService.searchProducts(query);
      _searchResults = results.map((product) {
        // Đảm bảo rằng sản phẩm có variations, nếu không thì thêm một variations mặc định
        if (product['variations'] == null || product['variations'].isEmpty) {
          return {
            ...product,
            'variations': [
              {
                'id': null,
                'color': 'Mặc định',
                'size': null,
                'price': product['gia'] ?? 0.0,
                'stock': 0,
                'images': [
                  {'image_url': 'https://picsum.photos/400/200'} // Hình ảnh mặc định
                ]
              }
            ]
          };
        }
        return product;
      }).toList();
      if (_searchResults.isEmpty) {
        _searchErrorMessage = "Không tìm thấy sản phẩm nào.";
      }
      print('Search results in ProductProvider: $_searchResults');
    } catch (e) {
      _searchErrorMessage = "Lỗi khi tìm kiếm sản phẩm: $e";
      _hasSearchError = true;
      _searchResults = [];
      print(_searchErrorMessage);
    }

    _isSearching = false;
    notifyListeners();
  }

  // Lấy sản phẩm gợi ý dựa trên danh mục
  Future<void> loadSuggestedProducts(int categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allProducts = await _productService.fetchProducts();
      _suggestedProducts = allProducts.where((prod) => prod['id_danhMuc'] == categoryId).toList();
      _suggestedProducts = _suggestedProducts.map((product) {
        // Đảm bảo rằng sản phẩm có variations, nếu không thì thêm một variations mặc định
        if (product['variations'] == null || product['variations'].isEmpty) {
          return {
            ...product,
            'variations': [
              {
                'id': null,
                'color': 'Mặc định',
                'size': null,
                'price': product['gia'] ?? 0.0,
                'stock': 0,
                'images': [
                  {'image_url': 'https://picsum.photos/400/200'} // Hình ảnh mặc định
                ]
              }
            ]
          };
        }
        return product;
      }).toList();
      if (_suggestedProducts.isEmpty) {
        _errorMessage = "Không có sản phẩm gợi ý nào.";
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải sản phẩm gợi ý: $e";
      _suggestedProducts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Làm mới danh sách sản phẩm
  Future<void> refreshProducts() async {
    await loadProducts();
  }

  // Thêm phương thức để lấy sản phẩm theo ID
  dynamic getProductById(int id) {
    return _products.firstWhere(
          (product) => product['id_sanPham'] == id,
      orElse: () => null,
    );
  }

  // Xóa kết quả tìm kiếm
  void clearSearch() {
    _searchResults = [];
    _searchErrorMessage = null;
    _hasSearchError = false;
    _isSearching = false;
    notifyListeners();
  }

  // Xóa danh sách đánh giá
  void clearReviews() {
    _reviews = [];
    _reviewsErrorMessage = null;
    _hasReviewsError = false;
    _isLoadingReviews = false;
    notifyListeners();
  }
}