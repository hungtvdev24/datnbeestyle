import 'package:flutter/material.dart';
import '../core/api/cart_service.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setCartItems(List<Map<String, dynamic>> items) {
    _cartItems = items;
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

  /// Load giỏ hàng từ API
  Future<void> loadCart(String token, BuildContext context) async {
    if (token.isEmpty) {
      setLoading(false);
      setErrorMessage('Vui lòng đăng nhập để xem giỏ hàng.');
      setCartItems([]);
      return;
    }
    setLoading(true);
    setErrorMessage(null);
    try {
      final response = await CartService.getCart(token);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (response['cart'] != null && response['cart']['muc_gio_hangs'] != null) {
        final items = List<Map<String, dynamic>>.from(
          response['cart']['muc_gio_hangs'].map((item) {
            final product = productProvider.getProductById(item['id_sanPham']);
            final variation = product?['variations']?.firstWhere(
                  (v) => v['id'] == item['variation_id'],
              orElse: () => null,
            ) ?? {'color': '', 'size': '', 'images': [], 'price': 0.0}; // Giá trị mặc định
            return {
              'id_mucGioHang': item['id_mucGioHang'],
              'id_sanPham': item['id_sanPham'],
              'variation_id': item['variation_id'],
              'soLuong': item['soLuong'],
              'gia': double.tryParse(variation['price']?.toString() ?? item['gia'].toString()) ?? 0.0, // Ưu tiên giá biến thể
              'name': item['product']?['tenSanPham'] ?? product?['tenSanPham'] ?? 'Không có tên',
              'thuongHieu': item['product']?['thuongHieu'] ?? product?['thuongHieu'] ?? 'Không có thương hiệu',
              'image': variation['images']?.isNotEmpty ?? false
                  ? variation['images'][0]['image_url']
                  : product?['urlHinhAnh'] ?? 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=150',
              'color': variation['color'] ?? '',
              'size': variation['size'] ?? '',
              'selected': false,
            };
          }),
        );
        setCartItems(items);
      } else {
        setCartItems([]);
        setErrorMessage('Giỏ hàng trống hoặc không có dữ liệu.');
      }
    } catch (e) {
      setErrorMessage('Lỗi khi tải giỏ hàng: ${e.toString()}');
      setCartItems([]);
    } finally {
      setLoading(false);
    }
  }

  /// Cập nhật số lượng một mục giỏ hàng
  Future<void> updateCartItemQuantity(String token, int idMucGioHang, int quantity, BuildContext context) async {
    if (quantity < 1) throw Exception('Số lượng phải >= 1');
    try {
      await CartService.updateCartItemQuantity(token, idMucGioHang, quantity);
      await loadCart(token, context);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật số lượng: $e');
    }
  }

  /// Xoá một mục khỏi giỏ hàng
  Future<void> removeCartItem(String token, int idMucGioHang, BuildContext context) async {
    try {
      await CartService.removeCartItem(token, idMucGioHang);
      await loadCart(token, context);
    } catch (e) {
      throw Exception('Lỗi khi xóa mục: $e');
    }
  }

  /// Thêm sản phẩm vào giỏ hàng với variation_id
  Future<void> addToCart(String token, int productId, int quantity, int variationId, BuildContext context) async {
    try {
      setLoading(true);
      await CartService.addToCart(token, productId, quantity, variationId);
      await loadCart(token, context);
    } catch (e) {
      setErrorMessage('Lỗi khi thêm sản phẩm vào giỏ hàng: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
}