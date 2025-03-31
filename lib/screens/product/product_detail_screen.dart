import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_product_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/recent_products_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách đánh giá khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadReviews(widget.product['id_sanPham'] as int);
    });
  }

  Future<void> _addToCart(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (userProvider.token == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thêm vào giỏ hàng!')),
      );
      return;
    }

    try {
      await cartProvider.addToCart(userProvider.token!, widget.product['id_sanPham'] as int, 1, context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Đã thêm vào giỏ hàng!')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  Future<void> _toggleFavorite(BuildContext context, {required int productId}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProductProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (userProvider.token == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thêm vào danh sách yêu thích!')),
      );
      return;
    }

    try {
      bool isFavorite = favoriteProvider.favorites.any((fav) => fav['id_sanPham'] == productId);
      if (isFavorite) {
        await favoriteProvider.removeFavoriteProduct(userProvider.token!, productId);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Đã xóa khỏi danh sách yêu thích!')),
        );
      } else {
        await favoriteProvider.addFavoriteProduct(userProvider.token!, productId);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Đã thêm vào danh sách yêu thích!')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product['urlHinhAnh'] ?? "http://10.0.3.2:8001/images/default.png";
    final productProvider = Provider.of<ProductProvider>(context);

    // Thêm sản phẩm vào lịch sử xem gần đây
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recentProductsProvider = Provider.of<RecentProductsProvider>(context, listen: false);
      recentProductsProvider.addRecentProduct(
        RecentProduct(
          id: widget.product['id_sanPham'] as int,
          name: widget.product['tenSanPham'] ?? "Không có tên",
          image: widget.product['urlHinhAnh'] ?? "http://10.0.3.2:8001/images/default.png",
          price: double.tryParse(widget.product['gia'].toString()) ?? 0.0,
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['tenSanPham'] ?? "Chi tiết sản phẩm"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error, size: 50));
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Consumer<FavoriteProductProvider>(
                    builder: (context, favoriteProvider, child) {
                      bool isFavorite = favoriteProvider.favorites.any((fav) => fav['id_sanPham'] == widget.product['id_sanPham']);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                        onPressed: () => _toggleFavorite(context, productId: widget.product['id_sanPham']),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['thuongHieu'] ?? "Không có thương hiệu",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['tenSanPham'] ?? "Không có tên",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.product['soSaoDanhGia'] ?? '0'} (126 Đánh giá)",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Còn hàng",
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Thông tin sản phẩm",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['moTa'] ?? "Không có mô tả",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${NumberFormat("#,###", "vi_VN").format(double.tryParse(widget.product['gia'].toString()) ?? 0)} ₫",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Phần hiển thị đánh giá
                  const Text(
                    "Đánh giá sản phẩm",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      if (productProvider.isLoadingReviews) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (productProvider.hasReviewsError) {
                        return Text(
                          productProvider.reviewsErrorMessage ?? "Lỗi khi tải đánh giá.",
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        );
                      } else if (productProvider.reviews.isEmpty) {
                        return const Text(
                          "Chưa có đánh giá nào cho sản phẩm này.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productProvider.reviews.length,
                        itemBuilder: (context, index) {
                          final review = productProvider.reviews[index];
                          final userName = review['user'] != null && review['user']['name'] != null
                              ? review['user']['name']
                              : "Người dùng ẩn danh";
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: List.generate(
                                          (review['soSao'] as int?) ?? 0,
                                              (i) => const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review['binhLuan'] ?? "Không có bình luận",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  if (review['urlHinhAnh'] != null)
                                    Image.network(
                                      review['urlHinhAnh'],
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const SizedBox();
                                      },
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm').format(
                                      DateTime.parse(review['created_at']),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addToCart(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Thêm vào giỏ hàng",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sản phẩm tương tự",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      if (productProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (productProvider.products.isEmpty) {
                        return const Text(
                          "Không có sản phẩm tương tự nào",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        );
                      }

                      final suggestedProducts = productProvider.products
                          .where((prod) =>
                      prod['id_danhMuc'] == widget.product['id_danhMuc'] &&
                          prod['id_sanPham'] != widget.product['id_sanPham'])
                          .toList();

                      if (suggestedProducts.isEmpty) {
                        return const Text(
                          "Không có sản phẩm tương tự nào",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: suggestedProducts.length > 2 ? 2 : suggestedProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final suggestedProduct = suggestedProducts[index];
                          return _buildSuggestedProductCard(context, suggestedProduct);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedProductCard(BuildContext context, dynamic suggestedProduct) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");
    final imageUrl = suggestedProduct['urlHinhAnh'] ?? "http://10.0.3.2:8001/images/default.png";
    final thuongHieu = suggestedProduct['thuongHieu'] ?? "Không có thương hiệu";
    final tenSanPham = suggestedProduct['tenSanPham'] ?? "Không có tên";
    final double originalPrice = double.tryParse(suggestedProduct['gia'].toString()) ?? 0.0;
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
            builder: (context) => ProductDetailScreen(product: suggestedProduct),
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<FavoriteProductProvider>(
                    builder: (context, favoriteProvider, child) {
                      bool isFavorite = favoriteProvider.favorites.any((fav) => fav['id_sanPham'] == suggestedProduct['id_sanPham']);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 24,
                        ),
                        onPressed: () => _toggleFavorite(context, productId: suggestedProduct['id_sanPham']),
                      );
                    },
                  ),
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