import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/models/user.dart';
import '../../providers/auth_provider.dart';
import '../profile/chat_screen.dart'; // This is used, so the warning might be a false positive
import '../../routes.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      // Fetch the list of users
      final response = await ApiClient.getUsers();

      // Fetch the current user's ID directly using ApiClient
      final currentUserData = await ApiClient.getUser();
      final currentUserId = currentUserData['id'];

      setState(() {
        _users = response
            .map<User>((json) => User.fromJson(json))
            .where((user) => user.id != currentUserId) // Loại bỏ chính người dùng hiện tại
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn người để chat',
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
              onPressed: _fetchUsers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      )
          : _users.isEmpty
          ? const Center(
        child: Text(
          'Không có người dùng nào.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Roboto',
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user.name[0].toUpperCase()),
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
            subtitle: Text(
              user.email,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.chat,
                arguments: {'receiver': user},
              );
            },
          );
        },
      ),
    );
  }
}