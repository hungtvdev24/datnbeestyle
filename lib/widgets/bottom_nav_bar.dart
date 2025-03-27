import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; // Thư viện icon đẹp

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white, // Giữ nền trắng, không cần viền
      selectedItemColor: Colors.blue, // Màu icon được chọn
      unselectedItemColor: Colors.grey.shade500, // Màu icon chưa chọn
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(icon: Icon(Iconsax.shop), label: "Shop"),
        BottomNavigationBarItem(icon: Icon(Iconsax.category), label: "Lọc"),
        BottomNavigationBarItem(icon: Icon(Iconsax.bookmark), label: "Yêu thích"),
        BottomNavigationBarItem(icon: Icon(Iconsax.shopping_bag), label: "Giỏ hàng"),
        BottomNavigationBarItem(icon: Icon(Iconsax.user), label: "Tài khoản"),
      ],
    );
  }
}