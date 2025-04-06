import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_product_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
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

    return Consumer2<ProductProvider, FavoriteProductProvider>(
      builder: (context, productProvider, favoriteProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
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
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => productProvider.loadSuggestedProducts(categoryId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Thử lại",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
          )
              : productProvider.suggestedProducts.isEmpty
              ? const Center(
            child: Text(
              "Không có sản phẩm nào trong danh mục này",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
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
              final isFavorite = favoriteProvider.favorites.any(
                    (fav) => fav['id_sanPham'] == product['id_sanPham'],
              );
              return _buildProductCard(
                context,
                product,
                isFavorite: isFavorite,
                onToggleFavorite: () {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  if (userProvider.token != null) {
                    if (isFavorite) {
                      favoriteProvider.removeFavoriteProduct(
                        userProvider.token!,
                        product['id_sanPham'],
                      );
                    } else {
                      favoriteProvider.addFavoriteProduct(
                        userProvider.token!,
                        product['id_sanPham'],
                      );
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
      BuildContext context,
      dynamic product, {
        required bool isFavorite,
        required VoidCallback onToggleFavorite,
      }) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    // Lấy URL hình ảnh từ variations
    String imageUrl;
    if (product['variations'] != null &&
        product['variations'].isNotEmpty &&
        product['variations'][0]['images'] != null &&
        product['variations'][0]['images'].isNotEmpty) {
      imageUrl = product['variations'][0]['images'][0]['image_url']?.toString() ??
          "https://picsum.photos/400/200";
    } else {
      imageUrl = "https://picsum.photos/400/200";
    }

    // Lấy size từ variations (nếu có)
    String? size;
    if (product['variations'] != null &&
        product['variations'].isNotEmpty &&
        product['variations'][0]['size'] != null) {
      size = product['variations'][0]['size'].toString();
    }

    // Lấy giá từ variation nếu có, nếu không thì lấy từ product['gia']
    final double price = product['variations'] != null &&
        product['variations'].isNotEmpty &&
        product['variations'][0]['price'] != null
        ? (double.tryParse(product['variations'][0]['price'].toString()) ?? 0.0)
        : (double.tryParse(product['gia'].toString()) ?? 0.0);

    final priceText = "${formatCurrency.format(price)} VNĐ";

    print("Image URL for product ${product['tenSanPham']}: $imageUrl");

    final thuongHieu = product['thuongHieu'] ?? "Không có thương hiệu";
    final tenSanPham = product['tenSanPham'] ?? "Không có tên";

    return GestureDetector(
      onTap: () {
        // Tạo dữ liệu sản phẩm để truyền vào ProductDetailScreen
        final productDetail = {
          'urlHinhAnh': imageUrl,
          'thuongHieu': thuongHieu,
          'tenSanPham': tenSanPham,
          'gia': price,
          'size': size,
          'id_sanPham': product['id_sanPham'],
          'id_danhMuc': product['id_danhMuc'],
          'moTa': product['moTa'] ?? "Không có mô tả",
          'soSaoDanhGia': product['soSaoDanhGia'] ?? 0,
          'variations': product['variations'] ?? [],
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: productDetail),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.2), // Viền đen mỏng, hơi nhạt
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12), // Bo góc
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
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
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC), // Màu hồng nhạt
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Like",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
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
                        fontFamily: 'Roboto',
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
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Roboto',
                      ),
                      overflow: TextOverflow.ellipsis,
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