import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/address_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/myorder_provider.dart';
import '../../core/models/address.dart';
import '../../core/models/voucher.dart';
import '../../routes.dart';
import '../../core/api/api_client.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final double totalPrice;

  const CheckoutScreen({
    Key? key,
    required this.selectedItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? selectedAddress;
  String paymentMethod = 'COD';
  Voucher? selectedVoucher;
  final TextEditingController _messageController = TextEditingController();
  double discountAmount = 0.0;
  double finalTotalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    finalTotalPrice = widget.totalPrice;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final voucherProvider = Provider.of<VoucherProvider>(context, listen: false);
      final token = userProvider.token;
      addressProvider.fetchAddresses(token!).then((_) {
        if (addressProvider.addresses.isNotEmpty) {
          setState(() {
            selectedAddress = addressProvider.addresses[0];
          });
        }
      });
      voucherProvider.fetchVouchers(token);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void applyVoucher(Voucher voucher) {
    if (!voucher.isUsable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher không khả dụng hoặc đã hết lượt sử dụng!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.totalPrice < (voucher.minOrderValue ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đơn hàng chưa đạt giá trị tối thiểu ${voucher.getFormattedMinOrderValue()} để sử dụng voucher này!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double total = widget.totalPrice;
    double discount = 0.0;

    if (voucher.discountType == 'fixed') {
      discount = voucher.discountValue;
    } else if (voucher.discountType == 'percentage') {
      final discountValue = voucher.discountValue;
      discount = (discountValue / 100) * total;
      final maxDiscount = voucher.maxDiscount ?? double.infinity;
      if (discount > maxDiscount) {
        discount = maxDiscount;
      }
    }

    setState(() {
      selectedVoucher = voucher;
      discountAmount = discount;
      finalTotalPrice = total - discount;
    });
  }

  Future<void> placeOrder(CheckoutProvider checkoutProvider, String token) async {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng!')),
      );
      return;
    }

    if (selectedVoucher != null && !selectedVoucher!.isUsable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher không khả dụng hoặc đã hết lượt sử dụng!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedVoucher != null && widget.totalPrice < (selectedVoucher!.minOrderValue ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đơn hàng chưa đạt giá trị tối thiểu ${selectedVoucher!.getFormattedMinOrderValue()} để sử dụng voucher này!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (paymentMethod == 'VN_PAY') {
      try {
        await checkoutProvider.getVNPayPaymentUrl(
          token: token,
          idDiaChi: selectedAddress!.idDiaChi,
          phuongThucThanhToan: paymentMethod,
          selectedItems: widget.selectedItems,
          message: _messageController.text,
          voucherCode: selectedVoucher?.code,
          totalAmount: finalTotalPrice,
        );

        if (checkoutProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(checkoutProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (checkoutProvider.qrCode != null && checkoutProvider.qrCode!.isNotEmpty) {
          final controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (NavigationRequest request) {
                  if (request.url.contains('/vnpay/return')) {
                    final uri = Uri.parse(request.url);
                    final responseCode = uri.queryParameters['vnp_ResponseCode'];
                    if (responseCode == '00') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanh toán và đặt hàng thành công')),
                      );
                      final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      if (userProvider.token != null) {
                        myOrderProvider.loadOrders(userProvider.token!);
                      }
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Thanh toán thất bại: Mã lỗi ${responseCode ?? "Không xác định"}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.pop(context);
                      Navigator.pop(context, false);
                    }
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
                onPageFinished: (url) {
                  if (url.contains('error')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Có lỗi xảy ra khi tải trang thanh toán VNPay'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                onWebResourceError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi tải trang thanh toán: ${error.description}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            )
            ..loadRequest(Uri.parse(checkoutProvider.qrCode!));

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Thanh toán VNPay')),
                body: WebViewWidget(controller: controller),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không nhận được URL thanh toán từ server. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thanh toán VNPay: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (paymentMethod == 'COD') {
      try {
        await checkoutProvider.placeOrder(
          token: token,
          idDiaChi: selectedAddress!.idDiaChi,
          phuongThucThanhToan: paymentMethod,
          selectedItems: widget.selectedItems,
          message: _messageController.text,
          voucherCode: selectedVoucher?.code,
        );

        if (checkoutProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(checkoutProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final msg = checkoutProvider.orderData?['message'] ?? 'Đặt hàng thành công!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green,
          ),
        );
        final myOrderProvider = Provider.of<MyOrderProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.token != null) {
          myOrderProvider.loadOrders(userProvider.token!);
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = Provider.of<CheckoutProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final voucherProvider = Provider.of<VoucherProvider>(context);
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
      body: checkoutProvider.isLoading || addressProvider.isLoading || voucherProvider.isLoading
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
                        }).toList(),
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
                    // Đảm bảo URL hình ảnh đầy đủ
                    final imageUrl = item['image'] != null && item['image'].isNotEmpty
                        ? (item['image'].startsWith('http')
                        ? item['image']
                        : '${ApiClient.storageUrl}/${item['image']}')
                        : 'https://via.placeholder.com/50';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
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
                                  item['name'] ?? 'Tên sản phẩm',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Biến thể: ${item['color'] ?? ''} - ${item['size'] ?? ''}",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${formatCurrency.format(double.tryParse(item['gia'].toString()) ?? 0)} ₫",
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
                  }).toList(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chọn Voucher',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.voucherList).then((value) {
                            if (value != null && value is Voucher && value.isUsable) {
                              applyVoucher(value);
                            }
                          });
                        },
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (voucherProvider.vouchers.isEmpty)
                    const Text(
                      'Chưa có voucher khả dụng',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Column(
                      children: [
                        DropdownButtonFormField<Voucher>(
                          value: selectedVoucher,
                          hint: const Text('Chọn voucher'),
                          items: voucherProvider.vouchers
                              .where((voucher) => voucher.isUsable && widget.totalPrice >= (voucher.minOrderValue ?? 0))
                              .map((voucher) {
                            return DropdownMenuItem<Voucher>(
                              value: voucher,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 300),
                                child: Text(
                                  "${voucher.code} - Giảm ${voucher.getFormattedDiscount()} (Đơn tối thiểu: ${voucher.getFormattedMinOrderValue()})",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              applyVoucher(value);
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        if (selectedVoucher != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Đã áp dụng voucher ${selectedVoucher!.code}: Giảm ${formatCurrency.format(discountAmount)} ₫',
                            style: const TextStyle(color: Colors.green, fontSize: 14),
                          ),
                        ],
                      ],
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
                        'Tổng tiền hàng',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "${formatCurrency.format(widget.totalPrice)} ₫",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Giảm giá',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "${formatCurrency.format(discountAmount)} ₫",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${formatCurrency.format(finalTotalPrice)} ₫",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
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

                    await placeOrder(checkoutProvider, token);
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