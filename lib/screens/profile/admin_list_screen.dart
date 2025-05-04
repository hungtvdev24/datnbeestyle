import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/admin.dart';
import '../../core/models/user.dart';
import '../profile/chat_screen.dart';
import '../../routes.dart';

class AdminListScreen extends StatefulWidget {
  const AdminListScreen({super.key});

  @override
  _AdminListScreenState createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen> {
  List<Admin> _admins = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    try {
      final response = await ApiClient.getAdmins();
      setState(() {
        _admins = response.map<Admin>((json) => Admin.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải danh sách admin. Vui lòng thử lại sau.';
        _isLoading = false;
      });
      print('Lỗi khi lấy danh sách admin: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat với Admin',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lỗi: $_error',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchAdmins,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      )
          : _admins.isEmpty
          ? const Center(
        child: Text(
          'Không có admin nào.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Roboto',
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _admins.length,
        itemBuilder: (context, index) {
          final admin = _admins[index];
          final userForChat = User(
            id: admin.id,
            name: admin.userNameAD,
            email: 'admin${admin.id}@example.com',
          );
          return ListTile(
            leading: CircleAvatar(
              child: Text(admin.userNameAD[0].toUpperCase()),
            ),
            title: Text(
              admin.userNameAD,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
            subtitle: const Text(
              'Admin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.chat,
                arguments: {'receiver': userForChat},
              );
            },
          );
        },
      ),
    );
  }
}