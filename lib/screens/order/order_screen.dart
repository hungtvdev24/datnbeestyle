import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/myorder_provider.dart';
import '../../providers/user_provider.dart';
import '../order/order_detail_screen.dart'; // Giả sử file này chứa màn hình chi tiết đơn hàng

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    if (userProvider.token != null) {
      myOrderProvider.loadOrders(userProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng sang trọng
      appBar: AppBar(
        title: const Text("Đơn hàng của tôi"),
        backgroundColor: Colors.grey[200], // Xám nhạt cho AppBar
        elevation: 0, // Loại bỏ bóng để giao diện phẳng
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          if (orderProvider.orders.isEmpty) {
            return const Center(
              child: Text(
                "Bạn chưa đặt đơn hàng nào.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0), // Khoảng cách đều xung quanh
            child: ListView.builder(
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                return Card(
                  color: Colors.white, // Card trắng
                  elevation: 2, // Bóng nhẹ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bo góc
                    side: BorderSide(color: Colors.grey[300]!), // Viền xám nhạt
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.shopping_bag_outlined, // Icon đơn hàng
                      color: Colors.grey[700],
                    ),
                    title: Text(
                      "Đơn hàng #${order['id_donHang']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Trạng thái: ${order['trangThaiDonHang']}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      "${order['tongTien']} VNĐ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailScreen(orderId: order['id_donHang']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}