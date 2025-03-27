import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/recent_products_provider.dart';
import '../../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userProvider.errorMessage != null || userProvider.userData == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Hồ sơ của tôi"),
              centerTitle: true,
              backgroundColor: Colors.blueAccent,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userProvider.errorMessage?['general']?.toString() ??
                        "Không thể tải thông tin người dùng",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => userProvider.fetchUserData(),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            ),
          );
        }

        final userData = userProvider.userData!;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(context, userData),
                  _buildPlanCard(),
                  _buildVoucherSection(),
                  _buildSectionTitle("Tài khoản"),
                  _buildProfileOptions(context),
                  _buildHistorySection(context),
                  const SizedBox(height: 20),
                  _buildLogoutButton(context, userProvider),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> userData) {
    final String userName = userData['name']?.toString() ?? "Người dùng";
    final String userEmail = userData['email']?.toString() ?? "email@unknown.com";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(
                "assets/avatar.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $userName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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

  Widget _buildPlanCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFAE52BB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Starter Plan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "All features unlocked!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("Upgrade"),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            "assets/upgrade_illustration.png",
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "🎉 Bạn có 3 voucher!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text("Xem ngay"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildProfileOption(
          Icons.shopping_bag,
          "Đơn hàng của tôi",
              () {
            Navigator.pushNamed(context, AppRoutes.order);
          },
        ),
        _buildProfileOption(
          Icons.autorenew,
          "Trả hàng (Returns)",
              () {},
        ),
        _buildProfileOption(
          Icons.favorite,
          "Sản phẩm yêu thích",
              () {},
        ),
        _buildProfileOption(
          Icons.location_on,
          "Địa chỉ giao hàng",
              () {
            Navigator.pushNamed(context, AppRoutes.addressList);
          },
        ),
        _buildProfileOption(
          Icons.payment,
          "Phương thức thanh toán",
              () {},
        ),
        _buildProfileOption(
          Icons.settings,
          "Cài đặt",
              () {},
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Consumer<RecentProductsProvider>(
      builder: (context, recentProductsProvider, child) {
        final recentProducts = recentProductsProvider.recentProducts;
        // Chỉ lấy tối đa 4 sản phẩm
        final displayedProducts = recentProducts.length > 4 ? recentProducts.sublist(0, 4) : recentProducts;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Lịch sử xem gần đây",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (recentProducts.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        recentProductsProvider.clearRecentProducts();
                      },
                      child: const Text(
                        "Xóa lịch sử",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              recentProducts.isEmpty
                  ? const Center(
                child: Text(
                  "Bạn chưa xem sản phẩm nào.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : Column(
                children: displayedProducts.map((product) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      "${product.price.toStringAsFixed(0)} VNĐ",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // Điều hướng đến màn hình chi tiết sản phẩm
                      Navigator.pushNamed(
                        context,
                        AppRoutes.productDetail,
                        arguments: {
                          'id_sanPham': product.id,
                          'tenSanPham': product.name,
                          'urlHinhAnh': product.image,
                          'gia': product.price,
                          'thuongHieu': "Thương hiệu", // Thêm thông tin nếu cần
                          'moTa': "Mô tả sản phẩm", // Thêm thông tin nếu cần
                          'soSaoDanhGia': 4.5, // Thêm thông tin nếu cần
                          'id_danhMuc': 1, // Thêm thông tin nếu cần
                        },
                      );
                    },
                  );
                }).toList(),
              ),
              if (recentProducts.length > 4) // Hiển thị nút "All" nếu có hơn 4 sản phẩm
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Điều hướng đến màn hình lịch sử đầy đủ
                      Navigator.pushNamed(context, AppRoutes.recentHistory);
                    },
                    child: const Text(
                      "All",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          userProvider.logout(context);
        },
        child: const Text(
          "Đăng xuất",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}