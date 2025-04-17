import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Danh sách ảnh cho 3 banner
  final List<List<String>> bannerImages = const [
    // Banner 1: 3 ảnh
    [
      "assets/anh11.png",
      "assets/anh12.png",
      "assets/anh13.png",
    ],
    // Banner 2: 3 ảnh
    [
      "assets/anh14.png",
      "assets/anh15.png",
      "assets/anh16.png",
    ],
    // Banner 3: 3 ảnh
    [
      "assets/anh17.png",
      "assets/anh18.png",
      "assets/anh19.png",
    ],
  ];

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
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.refreshProducts(),
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
            );
          }

          if (provider.products.isEmpty) {
            print("Products is empty");
            return const Center(
              child: SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Không có sản phẩm nào để hiển thị",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          print("Products: ${provider.products}");

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Banner 1 (Slide - Chỉ hiển thị ảnh)
                _buildBanner(imageUrls: bannerImages[0]),
                const SizedBox(height: 16),

                // 2. Sản phẩm phổ biến (lướt ngang)
                _buildProductSection("Sản phẩm phổ biến", provider.products, context),
                const SizedBox(height: 20),

                // 3. Banner 2 (Slide - Chỉ hiển thị ảnh)
                _buildBanner(imageUrls: bannerImages[1]),
                const SizedBox(height: 16),

                // 4. Banner 3 (Slide - Chỉ hiển thị ảnh)
                _buildBanner(imageUrls: bannerImages[2]),
                const SizedBox(height: 16),

                // 5. Hàng mới về (lướt ngang)
                _buildProductSection("Hàng mới về", provider.products, context),
                const SizedBox(height: 20),

                // 6. Sản phẩm nổi bật (lướt ngang)
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
  //  WIDGET BANNER (CHỈ HIỂN THỊ ẢNH DẠNG SLIDE)
  // --------------------------------------------------------------------------
  Widget _buildBanner({
    required List<String> imageUrls,
  }) {
    return Container(
      height: 200,
      width: double.infinity,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imageUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  KHỐI SẢN PHẨM (LƯỚT NGANG)
  // --------------------------------------------------------------------------
  Widget _buildProductSection(String title, List<dynamic> products, BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 220,
          child: Center(
            child: Text(
              "Không có sản phẩm nào cho \"$title\"",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      );
    }

    List<Widget> productWidgets = [];
    for (var product in products) {
      try {
        productWidgets.add(_buildProductCard(product, context));
      } catch (e) {
        print("Error rendering product: $e");
        productWidgets.add(
          Container(
            width: 150,
            height: 220,
            margin: const EdgeInsets.only(right: 16),
            child: const Center(child: Text("Lỗi hiển thị sản phẩm")),
          ),
        );
      }
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
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: productWidgets,
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
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    // Lấy URL hình ảnh từ variations
    String imageUrl = "https://picsum.photos/400/200";
    try {
      if (product['variations'] != null &&
          product['variations'].isNotEmpty &&
          product['variations'][0]['images'] != null &&
          product['variations'][0]['images'].isNotEmpty &&
          product['variations'][0]['images'][0]['image_url'] != null) {
        imageUrl = product['variations'][0]['images'][0]['image_url'].toString();
      }
    } catch (e) {
      print("Error accessing image URL: $e");
    }

    // Lấy giá từ variation nếu có, nếu không thì lấy từ product['gia']
    final double price = product['variations'] != null &&
        product['variations'].isNotEmpty &&
        product['variations'][0]['price'] != null
        ? (double.tryParse(product['variations'][0]['price'].toString()) ?? 0.0)
        : (double.tryParse(product['gia'].toString()) ?? 0.0);

    final priceText = "${formatCurrency.format(price)} VNĐ";

    final thuongHieu = product['thuongHieu']?.toString() ?? "Không có thương hiệu";
    final tenSanPham = product['tenSanPham']?.toString() ?? "Không có tên";
    final avgRating = double.tryParse(product['soSaoDanhGia']?.toString() ?? '0') ?? 0.0;

    return GestureDetector(
      onTap: () {
        final productDetail = {
          'urlHinhAnh': imageUrl,
          'thuongHieu': thuongHieu,
          'tenSanPham': tenSanPham,
          'gia': price,
          'id_sanPham': product['id_sanPham'],
          'id_danhMuc': product['id_danhMuc'],
          'moTa': product['moTa']?.toString() ?? "Không có mô tả",
          'soSaoDanhGia': avgRating,
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
        width: 150,
        margin: const EdgeInsets.only(right: 16),
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
            // Ảnh
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
                      print("Error loading image for $tenSanPham: $error");
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
              ],
            ),

            // Thông tin sản phẩm
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
                  mainAxisSize: MainAxisSize.min, // Đảm bảo Column không chiếm không gian thừa
                  children: [
                    // Thương hiệu
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
                    const SizedBox(height: 2), // Giảm khoảng cách

                    // Tên sản phẩm
                    Expanded(
                      child: Text(
                        tenSanPham,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                        ),
                        maxLines: 2, // Giới hạn tối đa 2 dòng
                        overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                      ),
                    ),
                    const SizedBox(height: 2), // Giảm khoảng cách

                    // Đánh giá sao
                    Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          index < avgRating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                          size: 14, // Giảm kích thước sao để tiết kiệm không gian
                        ),
                      ),
                    ),
                    const SizedBox(height: 2), // Giảm khoảng cách

                    // Giá
                    Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 1, // Đảm bảo giá chỉ chiếm 1 dòng
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