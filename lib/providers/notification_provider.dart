import 'package:flutter/material.dart';
import '../../core/models/notification.dart';
import '../../core/api/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final NotificationService _notificationService = NotificationService();

  // Lấy danh sách thông báo
  Future<void> fetchNotifications(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _notifications = await _notificationService.fetchNotifications(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đánh dấu thông báo là đã đọc
  Future<void> markAsRead(int notificationId, String token) async {
    try {
      await _notificationService.markAsRead(notificationId, token);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          content: _notifications[index].content,
          createdAt: _notifications[index].createdAt,
          isRead: true,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Làm mới danh sách thông báo
  Future<void> refreshNotifications(String token) async {
    await fetchNotifications(token);
  }
}