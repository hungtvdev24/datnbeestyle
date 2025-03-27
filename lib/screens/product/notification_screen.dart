import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../core/api/auth_service.dart';
import '../../routes.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    // Lấy token và tải thông báo khi khởi tạo màn hình
    final authService = AuthService();
    authService.getToken().then((token) {
      if (token != null) {
        setState(() {
          _token = token;
        });
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.black),
            onPressed: () {
              notificationProvider.refreshNotifications(_token!);
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${provider.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.refreshNotifications(_token!),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }
          if (provider.notifications.isEmpty) {
            return const Center(child: Text('Chưa có thông báo nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notifications.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead
                      ? Colors.grey.shade300
                      : Colors.blue.shade100,
                  child: Icon(
                    Iconsax.notification,
                    color: notification.isRead ? Colors.grey : Colors.blue,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  notification.content,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Iconsax.share, size: 20, color: Colors.grey),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.share,
                          arguments: {
                            'title': notification.title,
                            'content': notification.content,
                            'url': null,
                          },
                        );
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  if (!notification.isRead) {
                    await provider.markAsRead(notification.id, _token!);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}