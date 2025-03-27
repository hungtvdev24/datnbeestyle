import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    // Tải sản phẩm theo danh mục
    productProvider.loadSuggestedProducts(categoryId);

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(categoryName),
          ),
          body: productProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productProvider.errorMessage != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productProvider.errorMessage ?? "Lỗi không xác định",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => productProvider.loadSuggestedProducts(categoryId),
                  child: const Text("Thử lại"),
                ),
              ],
            ),
          )
              : productProvider.suggestedProducts.isEmpty
              ? const Center(
            child: Text(
              "Không có sản phẩm nào trong danh mục này",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: productProvider.suggestedProducts.length,
            itemBuilder: (context, index) {
              final product = productProvider.suggestedProducts[index];
              return _buildProductCard(context, product, isFavorite: false);
            },
          ),
        );
      },
    );
  }

  // Widget hiển thị thẻ sản phẩm
  Widget _buildProductCard(BuildContext context, dynamic product, {required bool isFavorite}) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    final imageUrl = product['urlHinhAnh']?.toString().startsWith('http') == true
        ? product['urlHinhAnh']
        : "https://72f7-104-28-254-73.ngrok-free.app/images/default.png";
    final thuongHieu = product['thuongHieu'] ?? "Không có thương hiệu";
    final tenSanPham = product['tenSanPham'] ?? "Không có tên";
    final double originalPrice = double.tryParse(product['gia'].toString()) ?? 0.0;

    const bool hasDiscount = true;
    const double discountPercent = 20;
    final double discountedPrice = originalPrice * (1 - discountPercent / 100);

    final discountedPriceText = "${formatCurrency.format(discountedPrice)} ₫";
    final originalPriceText = "${formatCurrency.format(originalPrice)} ₫";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading image for ${product['tenSanPham']}: $error");
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$discountPercent% GIẢM",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isFavorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: const Icon(Icons.favorite, color: Colors.red, size: 24),
                  ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thuongHieu,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tenSanPham,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            discountedPriceText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              originalPriceText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}