import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recent_products_provider.dart';
import '../../routes.dart';

class RecentHistoryScreen extends StatelessWidget {
  const RecentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử xem"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Consumer<RecentProductsProvider>(
        builder: (context, recentProductsProvider, child) {
          final recentProducts = recentProductsProvider.recentProducts;

          if (recentProducts.isEmpty) {
            return const Center(
              child: Text(
                "Bạn chưa xem sản phẩm nào.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recentProducts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final product = recentProducts[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
                  ),
                ),
                title: Text(product.name),
                subtitle: Text(
                  "${product.price.toStringAsFixed(0)} VNĐ",
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  // Điều hướng đến màn hình chi tiết sản phẩm
                  Navigator.pushNamed(
                    context,
                    AppRoutes.productDetail,
                    arguments: {
                      'id_sanPham': product.id,
                      'tenSanPham': product.name,
                      'urlHinhAnh': product.image,
                      'gia': product.price,
                      'thuongHieu': "Thương hiệu", // Thêm thông tin nếu cần
                      'moTa': "Mô tả sản phẩm", // Thêm thông tin nếu cần
                      'soSaoDanhGia': 4.5, // Thêm thông tin nếu cần
                      'id_danhMuc': 1, // Thêm thông tin nếu cần
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}