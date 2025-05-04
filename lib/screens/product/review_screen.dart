import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/myorder_provider.dart';
import '../product/product_detail_screen.dart';

class ReviewScreen extends StatefulWidget {
  final int orderId;
  final int productId;
  final int variationId;

  const ReviewScreen({
    super.key,
    required this.orderId,
    required this.productId,
    required this.variationId,
  });

  @override
  State<ReviewScreen> createState() => ReviewScreenState();
}

class ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final formatCurrency = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    if (userProvider.token != null) {
      myOrderProvider.loadOrderDetail(userProvider.token!, widget.orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, orderProvider, child) {
        final orderDetail = orderProvider.orderDetail;
        Map<String, dynamic>? productItem;

        if (orderDetail != null && orderDetail['chi_tiet_don_hang'] != null) {
          productItem = (orderDetail['chi_tiet_don_hang'] as List<dynamic>).firstWhere(
                (item) => item['id_sanPham'] == widget.productId && item['variation_id'] == widget.variationId,
            orElse: () => {},
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Đánh giá sản phẩm"),
            backgroundColor: const Color(0xFFFCE4EC),
            elevation: 0,
            titleTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: orderProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productItem == null || productItem.isEmpty
              ? const Center(
            child: Text(
              "Không tìm thấy sản phẩm trong đơn hàng.",
              style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Roboto'),
            ),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductCard(productItem, context),
                  const SizedBox(height: 24),
                  const Text(
                    "Chọn số sao:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow[700],
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Bình luận:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Nhập bình luận của bạn (không bắt buộc)",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    style: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  const SizedBox(height: 32),
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, child) {
                      return reviewProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_rating == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Vui lòng chọn số sao!",
                                    style: TextStyle(fontFamily: 'Roboto'),
                                  ),
                                ),
                              );
                              return;
                            }

                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            final success = await reviewProvider.submitReview(
                              userProvider.token!,
                              widget.orderId,
                              widget.productId,
                              widget.variationId,
                              _rating,
                              _commentController.text.isNotEmpty ? _commentController.text : null,
                              null,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Đánh giá đã được gửi thành công!",
                                    style: TextStyle(fontFamily: 'Roboto'),
                                  ),
                                ),
                              );
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    reviewProvider.errorMessage ?? "Lỗi khi gửi đánh giá",
                                    style: const TextStyle(fontFamily: 'Roboto'),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Gửi đánh giá",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(dynamic productItem, BuildContext context) {
    final String? thuongHieu = productItem['san_pham'] != null ? productItem['san_pham']['thuongHieu'] : null;
    final String? name = productItem['san_pham'] != null ? productItem['san_pham']['tenSanPham'] : null;
    final String? size = productItem['variation'] != null ? productItem['variation']['size'] : null;
    final double price = double.tryParse(productItem['gia']?.toString() ?? '0') ?? 0.0;
    final int productId = productItem['id_sanPham'] ?? 0; // Lấy id_sanPham
    final String? image = productItem['variation'] != null &&
        productItem['variation']['images'] != null &&
        (productItem['variation']['images'] as List).isNotEmpty
        ? "http://212a-104-28-254-73.ngrok-free.app/storage/${productItem['variation']['images'][0]['image_url']}"
        : null;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageSize = screenWidth * 0.15;

    return GestureDetector(
      onTap: () {
        final productDetail = {
          'id_sanPham': productId,
          'urlHinhAnh': image ?? "https://picsum.photos/150",
          'thuongHieu': thuongHieu,
          'tenSanPham': name,
          'gia': price,
          'size': size,
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: productDetail),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  image ?? "https://picsum.photos/150",
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint("Error loading image: $error, URL: $image");
                    return Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      width: imageSize,
                      height: imageSize,
                      child: const Text('No Image', style: TextStyle(fontFamily: 'Roboto')),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thuongHieu ?? "Không có thương hiệu",
                      style: TextStyle(
                        fontSize: screenWidth * 0.028,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name ?? "Không có tên",
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (size != null)
                      Text(
                        "Size: $size",
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.grey[600],
                          fontFamily: 'Roboto',
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      "${formatCurrency.format(price)} ₫",
                      style: TextStyle(
                        fontSize: screenWidth * 0.034,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}