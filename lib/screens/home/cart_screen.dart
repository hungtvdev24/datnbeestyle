import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Màn hình Checkout (nếu có)
import '../order/checkout_screen.dart';
// Màn hình chi tiết sản phẩm (nếu có)
import '../product/product_detail_screen.dart';

// Providers
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';

// RouteObserver (nếu bạn dùng)
import '../../main.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with RouteAware {
  final formatCurrency = NumberFormat("#,###", "vi_VN");
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
    _loadCart();
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
      debugPrint('Loaded cart items: ${cartProvider.cartItems}');
    } catch (e) {
      cartProvider.setErrorMessage('Lỗi khi tải giỏ hàng: $e');
    }
  }

  /// Chọn/Bỏ chọn một mục
  void _toggleSelect(int index) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final updatedItems = List<Map<String, dynamic>>.from(cartProvider.cartItems);
    updatedItems[index]['selected'] = !(updatedItems[index]['selected'] ?? false);
    cartProvider.setCartItems(updatedItems);
  }

  /// Tăng/giảm số lượng của một mục
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
      // Không hiển thị thông báo, chỉ tải lại giỏ hàng
      await _loadCart();
    } catch (e) {
      // Rollback nếu có lỗi
      updatedItems[index]['soLuong'] = currentQty;
      cartProvider.setCartItems(updatedItems);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật số lượng: $e')));
    }
  }

  /// Xoá các mục đã được chọn
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
    // Hiển thị dialog xác nhận
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa các mục đã chọn?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Hủy
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Đồng ý
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
    // Nếu người dùng đồng ý, tiến hành xóa
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
                // Danh sách giỏ hàng
                Expanded(
                  child: cartProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : cartProvider.errorMessage != null
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        cartProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                      : cartProvider.cartItems.isEmpty
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Giỏ hàng trống',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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

  /// Widget Header: "Chọn tất cả" & "Xóa mục đã chọn"
  Widget _buildHeader() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    activeColor: Colors.green,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              TextButton(
                onPressed: _removeSelectedItems,
                child: const Text("Xóa Mục Đã Chọn",
                    style: TextStyle(color: Colors.red, fontSize: 14)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Widget hiển thị một mục sản phẩm trong giỏ hàng
  Widget _buildCartItem(Map<String, dynamic> product, int index, BuildContext context) {
    final String? image = product['image'];
    final String? thuongHieu = product['thuongHieu'];
    final String? name = product['name'];
    final double originalPrice = product['gia'] as double;
    final int soLuong = product['soLuong'] ?? 1;

    // Tính discount (giả lập 20%)
    const double discountPercent = 20;
    final double discountedPrice = originalPrice * (1 - discountPercent / 100);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageSize = screenWidth * 0.15;
    final double arrowButtonSize = screenWidth * 0.04;

    return GestureDetector(
      onTap: () {
        final productDetail = {
          'urlHinhAnh': image,
          'thuongHieu': thuongHieu,
          'tenSanPham': name,
          'gia': originalPrice,
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
            // Checkbox chọn mục
            Checkbox(
              activeColor: Colors.green,
              value: product['selected'] ?? false,
              onChanged: (value) => _toggleSelect(index),
            ),
            // Hình ảnh sản phẩm
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                image ?? "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=150",
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    width: imageSize,
                    height: imageSize,
                    child: const Text('No Image'),
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
            // Nội dung sản phẩm
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildItemContent(
                    thuongHieu, name, originalPrice, discountedPrice, soLuong, index, context, arrowButtonSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Nội dung hiển thị thông tin sản phẩm trong mục giỏ hàng
  Widget _buildItemContent(
      String? thuongHieu,
      String? name,
      double originalPrice,
      double discountedPrice,
      int soLuong,
      int index,
      BuildContext context,
      double arrowButtonSize) {
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
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "${formatCurrency.format(discountedPrice)} ₫",
              style: TextStyle(
                fontSize: screenWidth * 0.034,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            Text(
              "${formatCurrency.format(originalPrice)} ₫",
              style: TextStyle(
                fontSize: screenWidth * 0.028,
                color: Colors.grey[600],
                decoration: TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Chức năng tăng / giảm số lượng
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => _updateQuantity(index, 1),
              icon: Icon(Icons.keyboard_arrow_up, size: arrowButtonSize, color: Colors.blue[700]),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Text(
              soLuong.toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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

  /// Mã giảm giá
  Widget _buildCouponSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mã giảm giá của bạn",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: _couponController,
            decoration: InputDecoration(
              hintText: "Nhập mã giảm giá",
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Thanh tóm tắt bên dưới
  Widget _buildBottomBar() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final selectedItems = cartProvider.cartItems.where((item) => item['selected'] == true).toList();
        double subtotal = 0;
        double discount = 0;
        const double shippingFee = 0;
        const double vatRate = 0.03;
        for (var product in selectedItems) {
          final double originalPrice = product['gia'] as double;
          const double discountPercent = 20;
          final double discountedPrice = originalPrice * (1 - discountPercent / 100);
          subtotal += discountedPrice * product['soLuong'];
        }
        if (_couponController.text.isNotEmpty) {
          discount = 10000.0;
        }
        final double total = subtotal + shippingFee - discount;
        final double estimatedVat = total * vatRate;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            children: [
              const Text("Tóm tắt đơn hàng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng phụ", style: TextStyle(fontSize: 14, color: Colors.black87)),
                  Text("${formatCurrency.format(subtotal)} ₫",
                      style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Phí vận chuyển", style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const Text("Miễn phí", style: TextStyle(fontSize: 14, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Giảm giá", style: TextStyle(fontSize: 14, color: Colors.black87)),
                  Text("-${formatCurrency.format(discount)} ₫",
                      style: const TextStyle(fontSize: 14, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng (bao gồm VAT)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text("${formatCurrency.format(total)} ₫",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("VAT ước tính", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text("${formatCurrency.format(estimatedVat)} ₫",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 16),
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
                    backgroundColor: selectedItems.isNotEmpty ? Colors.blue : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text("Tiếp tục",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}