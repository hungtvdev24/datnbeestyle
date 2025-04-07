import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/myorder_provider.dart';
import '../../providers/user_provider.dart';
import '../order/order_detail_screen.dart';
import '../product/product_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatCurrency = NumberFormat("#,###", "vi_VN");
  late final DateFormat dateTimeFormat;

  @override
  void initState() {
    super.initState();
    dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm", "vi_VN");
    _tabController = TabController(length: 5, vsync: this);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    if (userProvider.token != null) {
      myOrderProvider.loadOrders(userProvider.token!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đơn hàng của tôi"),
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black87,
          isScrollable: true,
          labelStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
          tabs: const [
            Tab(text: "Chờ xác nhận"),
            Tab(text: "Đang giao hàng"),
            Tab(text: "Đã giao"),
            Tab(text: "Đã hủy"),
            Tab(text: "Sản phẩm đã mua"),
          ],
        ),
      ),
      body: Consumer<MyOrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderProvider.errorMessage != null) {
            return Center(
              child: Text(
                orderProvider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16, fontFamily: 'Roboto'),
              ),
            );
          }
          if (orderProvider.orders.isEmpty) {
            return const Center(
              child: Text(
                "Bạn chưa đặt đơn hàng nào.",
                style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Roboto'),
              ),
            );
          }

          final choXacNhanOrders = orderProvider.orders.where((order) => order['trangThaiDonHang'] == 'cho_xac_nhan').toList();
          final dangGiaoOrders = orderProvider.orders.where((order) => order['trangThaiDonHang'] == 'dang_giao').toList();
          final daGiaoOrders = orderProvider.orders.where((order) => order['trangThaiDonHang'] == 'da_giao').toList();
          final daHuyOrders = orderProvider.orders.where((order) => order['trangThaiDonHang'] == 'huy').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(choXacNhanOrders, context),
              _buildOrderList(dangGiaoOrders, context),
              _buildOrderList(daGiaoOrders, context),
              _buildOrderList(daHuyOrders, context),
              _buildPurchasedProductsList(orderProvider.orders, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "Không có đơn hàng nào.",
          style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Roboto'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final double totalPrice = double.tryParse(order['tongTien']?.toString() ?? '0') ?? 0.0;
          final items = order['chi_tiet_don_hang'] as List<dynamic>;

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen(orderId: order['id_donHang']))).then((value) {
                if (value == true) {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
                  if (userProvider.token != null) {
                    myOrderProvider.loadOrders(userProvider.token!);
                  }
                }
              });
            },
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Đơn hàng #${order['id_donHang'] ?? 'N/A'}",
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
                      "Trạng thái: ${_mapStatus(order['trangThaiDonHang'] ?? '')}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Roboto'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ngày đặt: ${_formatDateTime(order['created_at'])}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Roboto'),
                    ),
                    if (order['ngay_du_kien_giao'] != null)
                      Text(
                        "Dự kiến giao: ${_formatDateTime(order['ngay_du_kien_giao'])}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Roboto'),
                      ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, itemIndex) {
                        return _buildOrderItem(items[itemIndex], context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderItem(dynamic item, BuildContext context) {
    final String? thuongHieu = item['san_pham'] != null ? item['san_pham']['thuongHieu'] : null;
    final String? name = item['san_pham'] != null ? item['san_pham']['tenSanPham'] : null;
    final String? size = item['variation'] != null ? item['variation']['size'] : null;
    final double price = double.tryParse(item['gia']?.toString() ?? '0') ?? 0.0;
    final int quantity = item['soLuong'] ?? 1;
    final int productId = item['id_sanPham'] ?? 0;
    final String? image = item['variation'] != null &&
        item['variation']['images'] != null &&
        (item['variation']['images'] as List).isNotEmpty
        ? "http://212a-104-28-254-73.ngrok-free.app/storage/${item['variation']['images'][0]['image_url']}"
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
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
                  debugPrint("Error loading image: $error");
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
    );
  }

  Widget _buildPurchasedProductsList(List<dynamic> orders, BuildContext context) {
    List<Map<String, dynamic>> purchasedProducts = [];
    for (var order in orders) {
      final items = order['chi_tiet_don_hang'] as List<dynamic>;
      for (var item in items) {
        purchasedProducts.add({
          'orderId': order['id_donHang'] ?? 0,
          'productId': item['id_sanPham'] ?? 0,
          'variationId': item['variation_id'] ?? 0,
          'productName': item['san_pham'] != null ? item['san_pham']['tenSanPham'] : "Sản phẩm #${item['id_sanPham']}",
          'productImage': item['variation'] != null && item['variation']['images'] != null && (item['variation']['images'] as List).isNotEmpty
              ? "http://212a-104-28-254-73.ngrok-free.app/storage/${item['variation']['images'][0]['image_url']}"
              : "https://picsum.photos/150",
          'price': item['gia'],
          'quantity': item['soLuong'] ?? 1,
          'thuongHieu': item['san_pham'] != null ? item['san_pham']['thuongHieu'] : null,
          'size': item['variation'] != null ? item['variation']['size'] : null,
        });
      }
    }

    if (purchasedProducts.isEmpty) {
      return const Center(
        child: Text(
          "Bạn chưa mua sản phẩm nào.",
          style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Roboto'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: purchasedProducts.length,
        itemBuilder: (context, index) {
          final product = purchasedProducts[index];
          final double screenWidth = MediaQuery.of(context).size.width;
          final double imageSize = screenWidth * 0.15;
          final double price = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;

          return GestureDetector(
            onTap: () {
              final productDetail = {
                'id_sanPham': product['productId'],
                'urlHinhAnh': product['productImage'],
                'thuongHieu': product['thuongHieu'],
                'tenSanPham': product['productName'],
                'gia': price,
                'size': product['size'],
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: productDetail),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      product['productImage'],
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint("Error loading purchased product image: $error");
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
                            product['thuongHieu'] ?? "Không có thương hiệu",
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
                            product['productName'] ?? "Không có tên",
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
                          if (product['size'] != null)
                            Text(
                              "Size: ${product['size']}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: Colors.grey[600],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            "Số lượng: ${product['quantity']}",
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
          );
        },
      ),
    );
  }
}