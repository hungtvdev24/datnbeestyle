import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentProduct {
  final int id;
  final String name;
  final String image;
  final double price;

  RecentProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
    };
  }

  factory RecentProduct.fromJson(Map<String, dynamic> json) {
    return RecentProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Không có tên",
      image: json['image'] ?? "",
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecentProductsProvider with ChangeNotifier {
  List<RecentProduct> _recentProducts = [];
  static const String _key = 'recent_products';

  List<RecentProduct> get recentProducts => _recentProducts;

  RecentProductsProvider() {
    _loadRecentProducts();
  }

  // Tải danh sách sản phẩm đã xem từ SharedPreferences
  Future<void> _loadRecentProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentProductsString = prefs.getString(_key);
    if (recentProductsString != null) {
      final List<dynamic> recentProductsJson = jsonDecode(recentProductsString);
      _recentProducts = recentProductsJson
          .map((json) => RecentProduct.fromJson(json))
          .toList();
      notifyListeners();
    }
  }

  // Thêm sản phẩm vào danh sách đã xem
  Future<void> addRecentProduct(RecentProduct product) async {
    // Kiểm tra xem sản phẩm đã tồn tại chưa
    final index = _recentProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      // Nếu đã tồn tại, xóa sản phẩm cũ và thêm lại vào đầu danh sách
      _recentProducts.removeAt(index);
    }

    // Thêm sản phẩm vào đầu danh sách
    _recentProducts.insert(0, product);

    // Giới hạn danh sách tối đa 10 sản phẩm
    if (_recentProducts.length > 10) {
      _recentProducts = _recentProducts.sublist(0, 10);
    }

    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_recentProducts.map((p) => p.toJson()).toList()));

    notifyListeners();
  }

  // Xóa toàn bộ lịch sử xem
  Future<void> clearRecentProducts() async {
    _recentProducts.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }
}