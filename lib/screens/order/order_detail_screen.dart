import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/myorder_provider.dart';
import '../../providers/user_provider.dart';
import '../product/product_detail_screen.dart';
import '../product/review_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final formatCurrency = NumberFormat("#,###", "vi_VN");
  late final DateFormat dateTimeFormat;
  Map<int, bool> _hasReviewed = {};

  @override
  void initState() {
    super.initState();
    dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm", "vi_VN");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderDetail();
    });
  }

  Future<void> _loadOrderDetail() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);

    if (userProvider.token != null) {
      await myOrderProvider.loadOrderDetail(userProvider.token!, widget.orderId);
      if (myOrderProvider.orderDetail != null) {
        final items = myOrderProvider.orderDetail!['chi_tiet_don_hang'] as List<dynamic>?;
        if (items != null) {
          for (var item in items) {
            final productId = item['id_sanPham'] ?? 0;
            final variationId = item['variation_id'] ?? 0;
            final hasReviewed = await myOrderProvider.hasReviewedProduct(
              userProvider.token!,
              widget.orderId,
              productId,
              variationId,
            );
            setState(() {
              _hasReviewed[productId] = hasReviewed;
            });
          }
        }
      }
    }
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'cho_xac_nhan':
        return 'Chờ xác nhận';
      case 'dang_giao':
        return 'Đang giao hàng';
      case 'da_giao':
        return 'Đã giao';
      case 'huy':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _formatDateTime(String? date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return dateTimeFormat.format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, orderProvider, child) {
        final orderDetail = orderProvider.orderDetail;
        final double totalPrice = double.tryParse(orderDetail?['tongTien']?.toString() ?? '0') ?? 0.0;
        final String orderStatus = orderDetail?['trangThaiDonHang'] ?? '';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Chi tiết đơn hàng"),
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
              : orderDetail == null
              ? const Center(
            child: Text(
              "Không tìm thấy chi tiết đơn hàng.",
              style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Roboto'),
            ),
          )
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(orderDetail, totalPrice),
                  const SizedBox(height: 16),
                  _buildOrderItems(orderDetail['chi_tiet_don_hang'], context, orderStatus),
                  const SizedBox(height: 16),
                  _buildShippingInfo(orderDetail),
                  const SizedBox(height: 16),
                  _buildPaymentInfo(orderDetail, totalPrice),
                  if (orderStatus == 'cho_xac_nhan') const SizedBox(height: 16),
                  if (orderStatus == 'cho_xac_nhan') _buildCancelButton(orderProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> orderDetail, double totalPrice) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đơn hàng #${orderDetail['id_donHang'] ?? 'N/A'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Roboto'),
                ),
                Text(
                  "${formatCurrency.format(totalPrice)} ₫",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Roboto'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Trạng thái: ${_mapStatus(orderDetail['trangThaiDonHang'] ?? '')}",
              style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 4),
            Text(
              "Ngày đặt: ${_formatDateTime(orderDetail['created_at'])}",
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Roboto'),
            ),
            if (orderDetail['ngay_du_kien_giao'] != null)
              Text(
                "Dự kiến giao: ${_formatDateTime(orderDetail['ngay_du_kien_giao'])}",
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Roboto'),
              ),
            if (orderDetail['updated_at'] != null)
              Text(
                "Cập nhật lần cuối: ${_formatDateTime(orderDetail['updated_at'])}",
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Roboto'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(List<dynamic>? items, BuildContext context, String orderStatus) {
    if (items == null || items.isEmpty) {
      return const Text(
        "Không có sản phẩm nào trong đơn hàng.",
        style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Roboto'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sản phẩm đã mua",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildOrderItem(items[index], context, orderStatus);
          },
        ),
      ],
    );
  }

  Widget _buildOrderItem(dynamic item, BuildContext context, String orderStatus) {
    final String? thuongHieu = item['san_pham'] != null ? item['san_pham']['thuongHieu'] : null;
    final String? name = item['san_pham'] != null ? item['san_pham']['tenSanPham'] : null;
    final String? size = item['variation'] != null ? item['variation']['size'] : null;
    final double price = double.tryParse(item['gia']?.toString() ?? '0') ?? 0.0;
    final int quantity = item['soLuong'] ?? 1;
    final int productId = item['id_sanPham'] ?? 0;
    final int variationId = item['variation_id'] ?? 0;
    final String? image = item['variation'] != null &&
        item['variation']['images'] != null &&
        (item['variation']['images'] as List).isNotEmpty
        ? "http://212a-104-28-254-73.ngrok-free.app/storage/${item['variation']['images'][0]['image_url']}"
        : null;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageSize = screenWidth * 0.15;
    final bool hasReviewed = _hasReviewed[productId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
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
                      debugPrint('Failed to load image: $image, error: $error');
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          maxLines: 1,
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
                        const SizedBox(height: 4),
                        Text(
                          "Số lượng: $quantity",
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Colors.grey[600],
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 6),
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
                ),
              ],
            ),
          ),
          if (orderStatus == 'da_giao')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: hasReviewed
                    ? const Text(
                  "Đã đánh giá",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                )
                    : ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewScreen(
                          orderId: widget.orderId,
                          productId: productId,
                          variationId: variationId,
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        setState(() {
                          _hasReviewed[productId] = true;
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Đánh giá",
                    style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(Map<String, dynamic> orderDetail) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin giao hàng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 8),
            Text(
              "Tên: ${orderDetail['ten_nguoiNhan'] ?? orderDetail['tenNguoiNhan'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 4),
            Text(
              "SĐT: ${orderDetail['sdt_nhanHang'] ?? orderDetail['soDienThoai'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 4),
            Text(
              "Địa chỉ: ${orderDetail['ten_nha'] ?? orderDetail['diaChiGiaoHang'] ?? 'N/A'}, ${orderDetail['xa'] ?? ''}, ${orderDetail['huyen'] ?? ''}, ${orderDetail['tinh'] ?? ''}",
              style: const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(Map<String, dynamic> orderDetail, double totalPrice) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin thanh toán",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng tiền hàng", style: TextStyle(fontSize: 14, fontFamily: 'Roboto')),
                Text("${formatCurrency.format(totalPrice)} ₫", style: const TextStyle(fontSize: 14, fontFamily: 'Roboto')),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Phí vận chuyển", style: TextStyle(fontSize: 14, fontFamily: 'Roboto')),
                Text("Miễn phí", style: TextStyle(fontSize: 14, color: Colors.green, fontFamily: 'Roboto')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Phương thức thanh toán", style: TextStyle(fontSize: 14, fontFamily: 'Roboto')),
                Text("${orderDetail['phuongThucThanhToan'] ?? 'N/A'}", style: const TextStyle(fontSize: 14, fontFamily: 'Roboto')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
                Text(
                  "${formatCurrency.format(totalPrice)} ₫",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Roboto'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(MyOrderProvider orderProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final success = await orderProvider.cancelOrder(userProvider.token!, widget.orderId);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đã hủy đơn hàng thành công!", style: TextStyle(fontFamily: 'Roboto'))),
            );
            await _loadOrderDetail();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(orderProvider.errorMessage ?? "Lỗi khi hủy đơn hàng", style: const TextStyle(fontFamily: 'Roboto')),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          "Hủy đơn hàng",
          style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 16),
        ),
      ),
    );
  }
}