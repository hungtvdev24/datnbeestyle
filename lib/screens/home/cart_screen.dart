import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../order/checkout_screen.dart';
import '../product/product_detail_screen.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../main.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with RouteAware {
  final formatCurrency = NumberFormat("#,###", "vi_VN");
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _loadCart();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.token == null) {
      cartProvider.setCartItems([]);
      cartProvider.setErrorMessage('Vui lòng đăng nhập để xem giỏ hàng.');
      return;
    }

    try {
      await cartProvider.loadCart(userProvider.token!, context);
    } catch (e) {
      cartProvider.setErrorMessage('Lỗi khi tải giỏ hàng: $e');
    }
  }

  void _toggleSelect(int index) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final updatedItems = List<Map<String, dynamic>>.from(cartProvider.cartItems);
    updatedItems[index]['selected'] = !(updatedItems[index]['selected'] ?? false);
    cartProvider.setCartItems(updatedItems);
  }

  Future<void> _updateQuantity(int index, int change) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để cập nhật giỏ hàng!')));
      return;
    }
    final updatedItems = List<Map<String, dynamic>>.from(cartProvider.cartItems);
    int currentQty = updatedItems[index]['soLuong'] ?? 1;
    int newQty = currentQty + change;
    if (newQty < 1) return;
    updatedItems[index]['soLuong'] = newQty;
    cartProvider.setCartItems(updatedItems);

    try {
      await cartProvider.updateCartItemQuantity(
          userProvider.token!, updatedItems[index]['id_mucGioHang'], newQty, context);
      await _loadCart();
    } catch (e) {
      updatedItems[index]['soLuong'] = currentQty;
      cartProvider.setCartItems(updatedItems);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật số lượng: $e')));
    }
  }

  Future<void> _removeSelectedItems() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để xóa mục!')));
      return;
    }
    final selectedItems = cartProvider.cartItems.where((item) => item['selected'] == true).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất một mục để xóa!')));
      return;
    }
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete,
                      color: Colors.black,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Xác nhận xóa",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: Text(
                  "Bạn có chắc chắn muốn xóa các mục đã chọn không?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.black),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.black),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Xác nhận",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (confirm == true) {
      for (var item in selectedItems) {
        try {
          await cartProvider.removeCartItem(userProvider.token!, item['id_mucGioHang'], context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi xóa mục: $e')));
          await _loadCart();
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa các mục đã chọn!')));
      await _loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            await _loadCart();
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Expanded(
                  child: cartProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : cartProvider.errorMessage != null
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cartProvider.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.blue, size: 32),
                            onPressed: _loadCart,
                            tooltip: 'Tải lại giỏ hàng',
                          ),
                          const Text(
                            'Thử lại',
                            style: TextStyle(
                              color: Colors.blue,
                              fontFamily: 'Roboto',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : cartProvider.cartItems.isEmpty
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Giỏ hàng trống',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  )
                      : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          itemCount: cartProvider.cartItems.length,
                          itemBuilder: (context, index) {
                            return _buildCartItem(
                                cartProvider.cartItems[index], index, context);
                          },
                        ),
                        _buildCouponSection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          color: const Color(0xFFFCE4EC),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    activeColor: Colors.pink,
                    value: cartProvider.cartItems.every((item) => item['selected'] == true),
                    onChanged: (value) {
                      final updated = List<Map<String, dynamic>>.from(cartProvider.cartItems);
                      for (var item in updated) {
                        item['selected'] = value ?? false;
                      }
                      cartProvider.setCartItems(updated);
                    },
                  ),
                  const Text(
                    "Chọn Tất Cả",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _removeSelectedItems,
                child: const Text(
                  "Xóa Mục Đã Chọn",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItem(Map<String, dynamic> product, int index, BuildContext context) {
    final String? image = product['image'];
    final String? thuongHieu = product['thuongHieu'];
    final String? name = product['name'] ?? product['tenSanPham'];
    final double originalPrice = product['gia'] as double;
    final int soLuong = product['soLuong'] ?? 1;
    final String? size = product['size'];
    final int productId = product['id_sanPham'] ?? 0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageSize = screenWidth * 0.15;
    final double arrowButtonSize = screenWidth * 0.04;

    final productDetail = {
      'urlHinhAnh': image ?? "https://picsum.photos/150",
      'thuongHieu': thuongHieu ?? "Không có thương hiệu",
      'tenSanPham': name ?? "Không có tên",
      'gia': originalPrice,
      'size': size,
      'id_sanPham': productId,
      'id_danhMuc': product['id_danhMuc'] ?? 0,
      'moTa': product['moTa'] ?? "Không có mô tả",
      'soSaoDanhGia': product['soSaoDanhGia'] ?? 0,
      'variations': product['variations'] ?? [],
    };

    return GestureDetector(
      onTap: () {
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
            Checkbox(
              activeColor: Colors.pink,
              value: product['selected'] ?? false,
              onChanged: (value) => _toggleSelect(index),
            ),
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
                child: _buildItemContent(
                  thuongHieu,
                  name,
                  originalPrice,
                  soLuong,
                  index,
                  context,
                  arrowButtonSize,
                  size,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemContent(
      String? thuongHieu,
      String? name,
      double originalPrice,
      int soLuong,
      int index,
      BuildContext context,
      double arrowButtonSize,
      String? size) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
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
          "${formatCurrency.format(originalPrice)} VNĐ",
          style: TextStyle(
            fontSize: screenWidth * 0.034,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Roboto',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => _updateQuantity(index, 1),
              icon: Icon(Icons.keyboard_arrow_up, size: arrowButtonSize, color: Colors.pink),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Text(
              soLuong.toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Roboto',
              ),
            ),
            IconButton(
              onPressed: () => _updateQuantity(index, -1),
              icon: Icon(Icons.keyboard_arrow_down, size: arrowButtonSize, color: Colors.grey[700]),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCouponSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mã giảm giá của bạn",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _couponController,
            decoration: InputDecoration(
              hintText: "Nhập mã giảm giá",
              hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(fontFamily: 'Roboto'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final selectedItems = cartProvider.cartItems.where((item) => item['selected'] == true).toList();
        double total = 0;
        for (var product in selectedItems) {
          final double originalPrice = product['gia'] as double;
          total += originalPrice * product['soLuong'];
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedItems.isNotEmpty
                      ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          selectedItems: selectedItems,
                          totalPrice: total,
                        ),
                      ),
                    );
                    if (result == true) await _loadCart();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedItems.isNotEmpty ? const Color(0xFFFCE4EC) : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    selectedItems.isNotEmpty
                        ? "Tiếp tục (${formatCurrency.format(total)} VNĐ)"
                        : "Tiếp tục",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}