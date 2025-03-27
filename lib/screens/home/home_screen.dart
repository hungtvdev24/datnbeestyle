import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm import này nếu muốn format tiền tệ
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.refreshProducts(),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }

          // Nếu có products, hiển thị giao diện
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Banner 1
                _buildBanner(
                  title: "BLACK FRIDAY\nBỘ SƯU TẬP",
                  discountText: "GIẢM 50%",
                  imageUrl: "https://via.placeholder.com/400x200.png?text=Black+Friday",
                ),
                const SizedBox(height: 16),

                // 2. Danh mục
                // _buildCategoryButtons(context),
                // const SizedBox(height: 16),

                // 3. Khối sản phẩm 1
                _buildProductSection("Sản phẩm phổ biến", provider.products, context),
                const SizedBox(height: 20),

                // 4. Banner 2
                _buildBanner(
                  title: "FS - MÙA MỚI",
                  discountText: "GIẢM 30%",
                  imageUrl: "https://via.placeholder.com/400x200.png?text=New+Season",
                ),
                const SizedBox(height: 16),

                // 5. Banner 3
                _buildBanner(
                  title: "BỘ SƯU TẬP MÙA XUÂN",
                  discountText: "GIẢM 20%",
                  imageUrl: "https://via.placeholder.com/400x200.png?text=Spring+Sale",
                ),
                const SizedBox(height: 16),

                // 6. Khối sản phẩm 2
                _buildProductSection("Hàng mới về", provider.products, context),
                const SizedBox(height: 20),

                // 7. Khối sản phẩm 3
                _buildProductSection("Sản phẩm nổi bật", provider.products, context),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  WIDGET BANNER (TÁI SỬ DỤNG)
  // --------------------------------------------------------------------------
  Widget _buildBanner({
    required String title,
    required String discountText,
    required String imageUrl,
  }) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: Colors.white,
                  child: Text(
                    discountText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Nút điều hướng (Next)
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              // Logic cho nút Next (nếu cần)
            },
          ),
        ),
        // Nút điều hướng (Previous)
        Positioned(
          left: 16,
          top: 0,
          bottom: 0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Logic cho nút Previous (nếu cần)
            },
          ),
        ),
        // Dots indicator (ví dụ 3 dots)
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 0 ? Colors.white : Colors.white.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  //  DANH MỤC
  // --------------------------------------------------------------------------
  // Widget _buildCategoryButtons(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         ElevatedButton(
  //           onPressed: () {
  //             // Logic cho nút "Tất cả danh mục"
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF6200EE), // Màu tím
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //           ),
  //           child: const Row(
  //             children: [
  //               Icon(Icons.category, size: 20, color: Colors.white),
  //               SizedBox(width: 8),
  //               Text(
  //                 "Tất cả danh mục",
  //                 style: TextStyle(color: Colors.white, fontSize: 14),
  //               ),
  //             ],
  //           ),
  //         ),
  //         OutlinedButton(
  //           onPressed: () {
  //             // Logic cho nút "Khuyến mãi"
  //           },
  //           style: OutlinedButton.styleFrom(
  //             side: BorderSide(color: Colors.grey),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //           ),
  //           child: const Row(
  //             children: [
  //               Icon(Icons.local_offer, size: 20, color: Colors.black54),
  //               SizedBox(width: 8),
  //               Text(
  //                 "Khuyến mãi",
  //                 style: TextStyle(color: Colors.black54, fontSize: 14),
  //               ),
  //             ],
  //           ),
  //         ),
  //         OutlinedButton(
  //           onPressed: () {
  //             // Logic cho nút "Nam"
  //           },
  //           style: OutlinedButton.styleFrom(
  //             side: BorderSide(color: Colors.grey),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //           ),
  //           child: const Row(
  //             children: [
  //               Icon(Icons.person, size: 20, color: Colors.black54),
  //               SizedBox(width: 8),
  //               Text(
  //                 "Nam",
  //                 style: TextStyle(color: Colors.black54, fontSize: 14),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // --------------------------------------------------------------------------
  //  KHỐI SẢN PHẨM
  // --------------------------------------------------------------------------
  Widget _buildProductSection(String title, List<dynamic> products, BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Không có sản phẩm nào cho \"$title\""),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(products[index], context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  CARD SẢN PHẨM
  // --------------------------------------------------------------------------
  Widget _buildProductCard(dynamic product, BuildContext context) {
    // Tạo format tiền Việt
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    // Lấy dữ liệu
    final imageUrl = product['urlHinhAnh'] ?? "http://10.0.3.2:8001/images/default.png";
    final thuongHieu = product['thuongHieu'] ?? "Không có thương hiệu";
    final tenSanPham = product['tenSanPham'] ?? "Không có tên";
    final double originalPrice = double.tryParse(product['gia'].toString()) ?? 0.0;

    // Giả lập giảm giá
    const bool hasDiscount = true; // tuỳ logic
    const double discountPercent = 20; // tuỳ logic
    final double discountedPrice = originalPrice * (1 - discountPercent / 100);

    // Chuyển sang chuỗi có đơn vị tiền tệ
    final discountedPriceText = "${formatCurrency.format(discountedPrice)} ₫";
    final originalPriceText = "${formatCurrency.format(originalPrice)} ₫";

    return GestureDetector(
      onTap: () {
        // Chuyển sang màn hình chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh + tag giảm giá
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
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
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
              ],
            ),

            // Thông tin sản phẩm
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thương hiệu
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

                    // Tên sản phẩm
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

                    // Giá
                    Row(
                      children: [
                        // Giá đã giảm
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
                          // Giá gốc gạch ngang
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
