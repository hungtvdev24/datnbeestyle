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
  int? selectedVariationId;
  Map<String, dynamic>? selectedVariation;
  int quantity = 1;
  int currentImageIndex = 0;
  late PageController _pageController;
  int visibleReviewsCount = 3; // Số lượng đánh giá hiển thị ban đầu

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadReviews(widget.product['id_sanPham'] as int);
      if (widget.product['variations'] != null && widget.product['variations'].isNotEmpty) {
        setState(() {
          selectedVariation = widget.product['variations'][0];
          selectedVariationId = selectedVariation!['id'];
        });
      }
      final recentProductsProvider = Provider.of<RecentProductsProvider>(context, listen: false);
      recentProductsProvider.addRecentProduct(
        RecentProduct(
          id: widget.product['id_sanPham'] as int,
          name: widget.product['tenSanPham'] ?? "Không có tên",
          image: selectedVariation != null && selectedVariation!['images'].isNotEmpty
              ? selectedVariation!['images'][0]['image_url']
              : widget.product['urlHinhAnh'] ?? "http://10.0.3.2:8001/images/default.png",
          price: selectedVariation != null
              ? (double.tryParse(selectedVariation!['price'].toString()) ?? 0.0)
              : (double.tryParse(widget.product['gia'].toString()) ?? 0.0),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    if (selectedVariationId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn biến thể sản phẩm!')),
      );
      return;
    }

    try {
      await cartProvider.addToCart(
        userProvider.token!,
        widget.product['id_sanPham'] as int,
        quantity,
        selectedVariationId!,
        context,
      );
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

  void _showAddToCartDialog(BuildContext context) {
    int tempQuantity = quantity;
    int? tempVariationId = selectedVariationId;
    Map<String, dynamic>? tempVariation = selectedVariation;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final variations = widget.product['variations'] as List<dynamic>;
            final colors = variations.map((v) => v['color']).toSet().toList();
            final sizesByColor = <String, List<String>>{};
            for (var variation in variations) {
              if (!sizesByColor.containsKey(variation['color'])) {
                sizesByColor[variation['color']] = [];
              }
              if (variation['size'] != null) {
                sizesByColor[variation['color']]!.add(variation['size']);
              }
            }

            final imageUrl = tempVariation != null && tempVariation!['images'].isNotEmpty
                ? tempVariation!['images'][0]['image_url']
                : widget.product['urlHinhAnh'] ?? "http://10.0.3.2:8001/images/default.png";
            final price = tempVariation != null
                ? (double.tryParse(tempVariation!['price'].toString()) ?? 0.0)
                : (double.tryParse(widget.product['gia'].toString()) ?? 0.0);

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "${NumberFormat("#,###", "vi_VN").format(price)} VNĐ",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Phân loại",
                    style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Loại",
                      style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colors.map((color) {
                        final isSelected = tempVariation != null && tempVariation!['color'] == color;
                        return OutlinedButton(
                          onPressed: () {
                            setStateDialog(() {
                              final variation = variations.firstWhere((v) => v['color'] == color);
                              tempVariation = variation;
                              tempVariationId = variation['id'];
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isSelected ? Colors.orange : Colors.black),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            color,
                            style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
                          ),
                        );
                      }).toList(),
                    ),
                    if (tempVariation != null && sizesByColor[tempVariation!['color']]!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        "Kích thước",
                        style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: sizesByColor[tempVariation!['color']]!.map((size) {
                          final isSelected = tempVariation!['size'] == size;
                          return OutlinedButton(
                            onPressed: () {
                              setStateDialog(() {
                                final variation = variations.firstWhere(
                                        (v) => v['color'] == tempVariation!['color'] && v['size'] == size);
                                tempVariation = variation;
                                tempVariationId = variation['id'];
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isSelected ? Colors.orange : Colors.black),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text(
                              size,
                              style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      "Số lượng",
                      style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: tempQuantity > 1
                              ? () => setStateDialog(() => tempQuantity--)
                              : null,
                          icon: const Icon(Icons.remove, color: Colors.black),
                        ),
                        Text(
                          "$tempQuantity",
                          style: const TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.black),
                        ),
                        IconButton(
                          onPressed: () => setStateDialog(() => tempQuantity++),
                          icon: const Icon(Icons.add, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedVariation = tempVariation;
                        selectedVariationId = tempVariationId;
                        quantity = tempQuantity;
                      });
                      Navigator.pop(context);
                      _addToCart(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Thêm vào giỏ hàng",
                      style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVariationSelector() {
    final variations = widget.product['variations'] as List<dynamic>;
    final colors = variations.map((v) => v['color']).toSet().toList();
    final sizesByColor = <String, List<String>>{};
    for (var variation in variations) {
      if (!sizesByColor.containsKey(variation['color'])) {
        sizesByColor[variation['color']] = [];
      }
      if (variation['size'] != null) {
        sizesByColor[variation['color']]!.add(variation['size']);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Màu sắc:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.black),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: colors.map((color) {
            final isSelected = selectedVariation != null && selectedVariation!['color'] == color;
            return OutlinedButton(
              onPressed: () {
                setState(() {
                  final variation = variations.firstWhere((v) => v['color'] == color);
                  selectedVariation = variation;
                  selectedVariationId = variation['id'];
                  currentImageIndex = variations.indexOf(variation);
                  _pageController.jumpToPage(currentImageIndex);
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isSelected ? Colors.orange : Colors.black),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                color,
                style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
              ),
            );
          }).toList(),
        ),
        if (selectedVariation != null && sizesByColor[selectedVariation!['color']]!.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Kích thước:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.black),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: sizesByColor[selectedVariation!['color']]!.map((size) {
              final isSelected = selectedVariation!['size'] == size;
              return OutlinedButton(
                onPressed: () {
                  setState(() {
                    final variation = variations.firstWhere(
                            (v) => v['color'] == selectedVariation!['color'] && v['size'] == size);
                    selectedVariation = variation;
                    selectedVariationId = variation['id'];
                    currentImageIndex = variations.indexOf(variation);
                    _pageController.jumpToPage(currentImageIndex);
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isSelected ? Colors.orange : Colors.black),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  size,
                  style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestedProductCard(BuildContext context, Map<String, dynamic> product) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");
    final imageUrl = product['variations'] != null &&
        product['variations'].isNotEmpty &&
        product['variations'][0]['images'] != null &&
        product['variations'][0]['images'].isNotEmpty
        ? product['variations'][0]['images'][0]['image_url']?.toString() ?? "https://picsum.photos/400/200"
        : "https://picsum.photos/400/200";
    final thuongHieu = product['thuongHieu'] ?? "Không có thương hiệu";
    final tenSanPham = product['tenSanPham'] ?? "Không có tên";
    final double originalPrice = double.tryParse(product['gia'].toString()) ?? 0.0;
    final originalPriceText = "${formatCurrency.format(originalPrice)} VNĐ";

    return GestureDetector(
      onTap: () {
        final productDetail = {
          'urlHinhAnh': imageUrl,
          'thuongHieu': thuongHieu,
          'tenSanPham': tenSanPham,
          'gia': originalPrice,
          'id_sanPham': product['id_sanPham'],
          'id_danhMuc': product['id_danhMuc'],
          'moTa': product['moTa'] ?? "Không có mô tả",
          'soSaoDanhGia': product['soSaoDanhGia'] ?? 0,
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
                      originalPriceText,
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

  @override
  Widget build(BuildContext context) {
    final variations = widget.product['variations'] as List<dynamic>? ?? [];
    final List<String> imageUrls = variations.isNotEmpty
        ? variations
        .map<String>((v) => v['images'].isNotEmpty
        ? v['images'][0]['image_url']
        : widget.product['urlHinhAnh'] ?? "http://10.0.3.2:8001/images/default.png")
        .toList()
        : [widget.product['urlHinhAnh'] ?? "http://10.0.3.2:8001/images/default.png"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.product['tenSanPham'] ?? "Chi tiết sản phẩm",
          style: const TextStyle(color: Colors.black, fontFamily: 'Roboto'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                        selectedVariation = variations[index];
                        selectedVariationId = variations[index]['id'];
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, size: 50)),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product['thuongHieu'] ?? "Không có thương hiệu",
                        style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Roboto'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product['tenSanPham'] ?? "Không có tên",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Consumer<ProductProvider>(
                            builder: (context, productProvider, child) {
                              final reviewCount = productProvider.reviews.length;
                              final avgRating = widget.product['soSaoDanhGia'] ?? 0;
                              return Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                          (index) => Icon(
                                        index < avgRating ? Icons.star : Icons.star_border,
                                        color: Colors.yellow,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$avgRating ($reviewCount lượt đánh giá)",
                                    style: const TextStyle(fontSize: 16, fontFamily: 'Roboto', color: Colors.black),
                                  ),
                                ],
                              );
                            },
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedVariation != null && selectedVariation!['stock'] > 0 ? "Còn hàng" : "Hết hàng",
                              style: const TextStyle(color: Colors.green, fontSize: 14, fontFamily: 'Roboto'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (variations.isNotEmpty) ...[
                        const Text(
                          "Chọn kiểu loại",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        _buildVariationSelector(),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        "${NumberFormat("#,###", "vi_VN").format(selectedVariation != null ? (double.tryParse(selectedVariation!['price'].toString()) ?? 0.0) : (double.tryParse(widget.product['gia'].toString()) ?? 0.0))} VNĐ",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Thông tin sản phẩm",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product['moTa'] ?? "Không có mô tả",
                        style: const TextStyle(fontSize: 16, fontFamily: 'Roboto', color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Đánh giá sản phẩm",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          if (productProvider.isLoadingReviews) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (productProvider.hasReviewsError) {
                            return Text(
                              productProvider.reviewsErrorMessage ?? "Lỗi khi tải đánh giá.",
                              style: const TextStyle(color: Colors.red, fontSize: 16, fontFamily: 'Roboto'),
                            );
                          } else if (productProvider.reviews.isEmpty) {
                            return const Text(
                              "Chưa có đánh giá nào cho sản phẩm này.",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Roboto'),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: visibleReviewsCount > productProvider.reviews.length
                                    ? productProvider.reviews.length
                                    : visibleReviewsCount,
                                itemBuilder: (context, index) {
                                  final review = productProvider.reviews[index];
                                  final userName = review['user'] != null && review['user']['name'] != null
                                      ? review['user']['name']
                                      : "Người dùng ẩn danh";
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200], // Nền màu xám
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                                  fontFamily: 'Roboto',
                                                  color: Colors.black),
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: List.generate(
                                                (review['soSao'] as int?) ?? 0,
                                                    (i) => const Icon(Icons.star, color: Colors.yellow, size: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          review['binhLuan'] ?? "Không có bình luận",
                                          style: const TextStyle(fontSize: 16, fontFamily: 'Roboto', color: Colors.black87),
                                        ),
                                        const SizedBox(height: 8),
                                        if (review['urlHinhAnh'] != null)
                                          Image.network(
                                            review['urlHinhAnh'],
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(review['created_at'])),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Roboto'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (visibleReviewsCount < productProvider.reviews.length)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      visibleReviewsCount += 3;
                                    });
                                  },
                                  child: const Text(
                                    "Xem thêm",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Có thể bạn sẽ thích",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          if (productProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (productProvider.products.isEmpty) {
                            return const Text(
                              "Không có sản phẩm tương tự nào",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Roboto'),
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
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Roboto'),
                            );
                          }
                          return Column(
                            children: [
                              SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: suggestedProducts.length > 4 ? 4 : suggestedProducts.length,
                                  itemBuilder: (context, index) {
                                    final suggestedProduct = suggestedProducts[index];
                                    return Container(
                                      width: 150,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: _buildSuggestedProductCard(context, suggestedProduct),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (suggestedProducts.length > 4)
                                SizedBox(
                                  height: 220,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: suggestedProducts.length > 8 ? 4 : suggestedProducts.length - 4,
                                    itemBuilder: (context, index) {
                                      final suggestedProduct = suggestedProducts[index + 4];
                                      return Container(
                                        width: 150,
                                        margin: const EdgeInsets.only(right: 12),
                                        child: _buildSuggestedProductCard(context, suggestedProduct),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Consumer<FavoriteProductProvider>(
                      builder: (context, favoriteProvider, child) {
                        bool isFavorite =
                        favoriteProvider.favorites.any((fav) => fav['id_sanPham'] == widget.product['id_sanPham']);
                        return OutlinedButton(
                          onPressed: () => _toggleFavorite(context, productId: widget.product['id_sanPham']),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 16), // Đảm bảo chiều cao bằng nhau
                            minimumSize: const Size(0, 50),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.black,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => _showAddToCartDialog(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 16), // Đảm bảo chiều cao bằng nhau
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 16), // Đảm bảo chiều cao bằng nhau
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text(
                        "Mua ngay",
                        style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}