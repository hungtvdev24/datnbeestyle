import 'package:datnbeestyle/core/models/notification.dart';
import 'api_client.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class NotificationService {
  // Lấy danh sách thông báo
  Future<List<AppNotification>> fetchNotifications(String token) async {
    try {
      final response = await ApiClient.getData('notifications', token: token);
      debugPrint('Raw API response: $response'); // Log dữ liệu thô
      if (response is List) {
        final notifications = response.map((json) => AppNotification.fromJson(json)).toList();
        debugPrint('Parsed notifications: $notifications'); // Log dữ liệu sau parse
        return notifications;
      } else {
        debugPrint('Unexpected response format: $response');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
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