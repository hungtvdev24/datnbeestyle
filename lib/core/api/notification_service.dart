import 'package:datnbeestyle/core/models/notification.dart';
import 'api_client.dart';

class NotificationService {
  // Lấy danh sách thông báo
  Future<List<AppNotification>> fetchNotifications(String token) async {
    try {
      final response = await ApiClient.getData('notifications', token: token);
      return (response as List).map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy thông báo: $e');
    }
  }

  // Đánh dấu thông báo là đã đọc
  Future<void> markAsRead(int notificationId, String token) async {
    try {
      await ApiClient.postData('notifications/$notificationId/read', {}, token: token);
    } catch (e) {
      throw Exception('Lỗi khi đánh dấu thông báo: $e');
    }
  }
}