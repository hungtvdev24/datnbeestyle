import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Thay bằng ảnh thật
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Trần Hùng',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('tranvanhung@gmail.com'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text(
                  'Good night\nNhận ưu đãi voucher',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Nâng cấp Pro'),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildListTile(Icons.list, 'Danh sách', () {}),
                _buildListTile(Icons.shopping_cart, 'Giỏ hàng', () {}),
                _buildListTile(Icons.lock, 'Đổi mật khẩu', () {}),
                _buildListTile(Icons.language, 'Ngôn ngữ', () {}),
                _buildListTile(Icons.account_balance_wallet, 'Ví của tôi', () {}),
                _buildListTile(Icons.favorite, 'Sản phẩm ưu thích', () {}),
                const Divider(),
                _buildListTile(Icons.help, 'Trợ giúp', () {}),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Log out', style: TextStyle(color: Colors.red)),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
