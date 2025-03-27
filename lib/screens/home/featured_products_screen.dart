import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format tiền tệ
import 'package:provider/provider.dart';
import '../../providers/favorite_product_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../product/product_detail_screen.dart';

class FeaturedProductsScreen extends StatefulWidget {
  const FeaturedProductsScreen({super.key});

  @override
  State<FeaturedProductsScreen> createState() => _FeaturedProductsScreenState();
}

class _FeaturedProductsScreenState extends State<FeaturedProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Lấy các provider cần thiết mà không lắng nghe trong initState
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProductProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    // Tải dữ liệu nếu có token
    if (userProvider.token != null) {
      favoriteProvider.loadFavoriteProducts(userProvider.token!);
      productProvider.loadProducts(); // Tải danh sách sản phẩm gợi ý
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoriteProductProvider, ProductProvider>(
      builder: (context, favoriteProvider, productProvider, child) {
        // Xử lý trạng thái loading chung
        if (favoriteProvider.isLoading && productProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Giao diện chính
        return Scaffold(

          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Phần sản phẩm yêu thích**
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (favoriteProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (favoriteProvider.errorMessage != null)
                        favoriteProvider.errorMessage!.contains("404")
                            ? const Center(
                          child: Text(
                            "Chưa có sản phẩm nào",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              favoriteProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                if (userProvider.token != null) {
                                  favoriteProvider.loadFavoriteProducts(userProvider.token!);
                                }
                              },
                              child: const Text("Thử lại"),
                            ),
                          ],
                        )
                      else if (favoriteProvider.favorites.isEmpty)
                          const Center(
                            child: Text(
                              "Chưa có sản phẩm nào",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: favoriteProvider.favorites.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final favorite = favoriteProvider.favorites[index];
                              // Tìm sản phẩm gốc từ ProductProvider dựa trên id_sanPham
                              final product = productProvider.products.firstWhere(
                                    (prod) => prod['id_sanPham'] == favorite['id_sanPham'],
                                orElse: () => favorite, // Nếu không tìm thấy, dùng dữ liệu từ favorite
                              );
                              return _buildProductCard(context, product, isFavorite: true);
                            },
                          ),
                    ],
                  ),
                ),

                // **Phần gợi ý sản phẩm**
                _buildSuggestedProductsSection(productProvider, context),
              ],
            ),
          ),
        );
      },
    );
  }

  // **Widget hiển thị phần gợi ý sản phẩm**
  Widget _buildSuggestedProductsSection(ProductProvider productProvider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sản phẩm khác",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          if (productProvider.isLoading)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (productProvider.errorMessage != null)
            Column(
              children: [
                Text(
                  productProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => productProvider.loadProducts(),
                  child: const Text("Thử lại"),
                ),
              ],
            )
          else if (productProvider.products.isEmpty)
              const Text(
                "Không có sản phẩm nào",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productProvider.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return _buildProductCard(context, product, isFavorite: false);
                },
              ),
        ],
      ),
    );
  }

  // **Widget hiển thị thẻ sản phẩm**
  Widget _buildProductCard(BuildContext context, dynamic product, {required bool isFavorite}) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    // In URL để debug
    print("Image URL for product ${product['tenSanPham']}: ${product['urlHinhAnh']}");

    // Lấy dữ liệu sản phẩm
    final imageUrl = product['urlHinhAnh']?.toString().startsWith('http') == true
        ? product['urlHinhAnh']
        : "http://10.0.3.2:8001/images/default.png"; // Thay 10.0.3.2 bằng IP của bạn nếu cần
    final thuongHieu = product['thuongHieu'] ?? "Không có thương hiệu";
    final tenSanPham = product['tenSanPham'] ?? "Không có tên";
    final double originalPrice = double.tryParse(product['gia'].toString()) ?? 0.0;

    // Giả lập giảm giá
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
            // Ảnh sản phẩm + tag giảm giá
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
            // Thông tin sản phẩm
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