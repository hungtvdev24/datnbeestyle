import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/address.dart';
import '../../providers/address_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final double totalPrice;

  const CheckoutScreen({
    super.key,
    required this.selectedItems,
    required this.totalPrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? selectedAddress;
  String paymentMethod = 'COD';
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final token = userProvider.token;
      if (token != null) {
        addressProvider.fetchAddresses(token).then((_) {
          if (addressProvider.addresses.isNotEmpty) {
            setState(() {
              selectedAddress = addressProvider.addresses[0];
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để tiếp tục!')),
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = Provider.of<CheckoutProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: checkoutProvider.isLoading || addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Địa chỉ giao hàng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.addressList).then((_) {
                            final token = userProvider.token;
                            if (token != null) {
                              addressProvider.fetchAddresses(token).then((_) {
                                if (addressProvider.addresses.isNotEmpty && selectedAddress == null) {
                                  setState(() {
                                    selectedAddress = addressProvider.addresses[0];
                                  });
                                }
                              });
                            }
                          });
                        },
                        child: Text(
                          addressProvider.addresses.isEmpty ? 'Thêm địa chỉ' : 'Xem tất cả',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (addressProvider.addresses.isEmpty)
                    const Text(
                      'Chưa có địa chỉ nào, vui lòng thêm địa chỉ để tiếp tục!',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Column(
                      children: [
                        ...addressProvider.addresses.map((addr) {
                          return RadioListTile<Address>(
                            value: addr,
                            groupValue: selectedAddress,
                            onChanged: (value) {
                              setState(() {
                                selectedAddress = value;
                              });
                            },
                            title: Text(
                              addr.tenNguoiNhan,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${addr.tenNha}, ${addr.xa}, ${addr.huyen}, ${addr.tinh}",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                ),
                                Text(
                                  "SDT: ${addr.sdtNhanHang}",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                ),
                              ],
                            ),
                            activeColor: Colors.blue,
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.addressList).then((_) {
                                final token = userProvider.token;
                                if (token != null) {
                                  addressProvider.fetchAddresses(token).then((_) {
                                    if (addressProvider.addresses.isNotEmpty && selectedAddress == null) {
                                      setState(() {
                                        selectedAddress = addressProvider.addresses[0];
                                      });
                                    }
                                  });
                                }
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Thêm địa chỉ mới',
                              style: TextStyle(color: Colors.blue, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Phần sản phẩm
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sản phẩm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...widget.selectedItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['image'] ?? 'https://via.placeholder.com/50',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['tenSanPham'] ?? 'Tên sản phẩm',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Bảo vệ sản phẩm được bảo hiểm khi thiết hại xảy ra do sự bất ngờ, tiếp xúc với chất lỏng hoặc hư hỏng trong quá trình sử dụng.",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${formatCurrency.format(double.tryParse(item['giaTien'].toString()) ?? 0)} ₫",
                                      style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "x${item['soLuong'] ?? 1}",
                                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lời nhắn cho Shop',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ghi chú đơn hàng (nếu có)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn Phương Thức Thanh Toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('Thanh toán khi nhận hàng (COD)'),
                    value: 'COD',
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value ?? 'COD';
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  RadioListTile<String>(
                    title: const Text('Thanh toán bằng VN Pay'),
                    value: 'VN_PAY',
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value ?? 'VN_PAY';
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${formatCurrency.format(widget.totalPrice)} ₫",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tiết kiệm',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "${formatCurrency.format(widget.totalPrice * 0.1)} ₫", // Giả định tiết kiệm 10%
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedAddress == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng!')),
                      );
                      return;
                    }

                    final token = userProvider.token;
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bạn chưa đăng nhập!')),
                      );
                      return;
                    }

                    await checkoutProvider.placeOrder(
                      token: token,
                      idDiaChi: selectedAddress!.idDiaChi,
                      phuongThucThanhToan: paymentMethod,
                      selectedItems: widget.selectedItems,
                      message: _messageController.text,
                    );

                    if (checkoutProvider.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(checkoutProvider.errorMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      final msg = checkoutProvider.orderData?['message'] ?? 'Đặt hàng thành công!';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Đặt hàng',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}