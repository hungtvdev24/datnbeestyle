import 'package:flutter/material.dart';
import '../core/api/chat_service.dart';
import '../core/models/message.dart';
import '../core/models/notification.dart'; // Cập nhật đường dẫn dựa trên cấu trúc thư mục
import 'dart:async';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  int? _currentReceiverId;
  String? _currentReceiverType;
  int? _currentUserId;

  List<Message> get messages => _messages;
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentUserId => _currentUserId; // Getter public cho _currentUserId
  int get unreadCount {
    return _messages.where((msg) => !msg.isRead && msg.receiverId == _currentUserId).length +
        _notifications.where((notif) => !notif.isRead).length;
  }

  final ChatService _chatService = ChatService();

  /// Lấy danh sách tin nhắn từ API
  Future<void> fetchMessages(
      int receiverId,
      int currentUserId,
      BuildContext context, {
        String receiverType = 'App\\Models\\User',
      }) async {
    _isLoading = true;
    _error = null;
    _currentReceiverId = receiverId;
    _currentReceiverType = receiverType;
    _currentUserId = currentUserId;
    notifyListeners();

    try {
      final messages = await _chatService.fetchMessages(receiverId, receiverType: receiverType);
      _messages = messages.where((msg) {
        final isMatch = (msg.senderId == currentUserId && msg.senderType == 'App\\Models\\User' &&
            msg.receiverId == receiverId && msg.receiverType == receiverType) ||
            (msg.senderId == receiverId && msg.senderType == receiverType &&
                msg.receiverId == currentUserId && msg.receiverType == 'App\\Models\\User');
        return isMatch;
      }).toList();
    } catch (e) {
      _error = 'Lỗi khi lấy tin nhắn: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy danh sách thông báo từ API
  Future<void> fetchNotifications(int currentUserId, BuildContext context) async {
    _isLoading = true;
    _error = null;
    _currentUserId = currentUserId;
    notifyListeners();

    try {
      final notificationsData = await _chatService.fetchNotifications(currentUserId);
      final notifications = notificationsData.map((json) => AppNotification.fromJson(json)).toList();
      _notifications = notifications;
    } catch (e) {
      _error = 'Lỗi khi lấy thông báo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gửi tin nhắn mới
  Future<void> sendMessage(
      int receiverId,
      String content,
      int currentUserId,
      BuildContext context, {
        String receiverType = 'App\\Models\\User',
      }) async {
    // Lưu trữ NavigatorState để tránh sử dụng BuildContext qua async gap
    final navigator = Navigator.of(context);
    try {
      if (currentUserId == 0) {
        throw Exception('Không thể lấy ID người dùng hiện tại. Vui lòng đăng nhập lại.');
      }
      await _chatService.sendMessage(receiverId, content, receiverType: receiverType);
      await fetchMessages(receiverId, currentUserId, context, receiverType: receiverType);
    } catch (e) {
      _error = 'Lỗi khi gửi tin nhắn: $e';
      notifyListeners();
      if (_error!.contains('Không thể lấy ID người dùng hiện tại') || _error!.contains('Không tìm thấy token')) {
        navigator.pushReplacementNamed('/login');
      }
    }
  }

  /// Đánh dấu tin nhắn đã đọc
  Future<void> markAsRead(int messageId) async {
    try {
      await _chatService.markAsRead(messageId);
      final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        _messages[messageIndex].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi khi đánh dấu tin nhắn đã đọc: $e');
    }
  }

  /// Đánh dấu thông báo đã đọc
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _chatService.markNotificationAsRead(notificationId);
      final notificationIndex = _notifications.indexWhere((notif) => notif.id == notificationId);
      if (notificationIndex != -1) {
        _notifications[notificationIndex].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi khi đánh dấu thông báo đã đọc: $e');
    }
  }

  /// Thêm tin nhắn mới vào danh sách
  void addMessage(Message message) {
    if (_currentReceiverId == null || _currentUserId == null || _currentReceiverType == null) return;
    final isMatch = (message.senderId == _currentUserId && message.senderType == 'App\\Models\\User' &&
        message.receiverId == _currentReceiverId && message.receiverType == _currentReceiverType) ||
        (message.senderId == _currentReceiverId && message.senderType == _currentReceiverType &&
            message.receiverId == _currentUserId && message.receiverType == 'App\\Models\\User');
    if (isMatch) {
      _messages.add(message);
      notifyListeners();
    }
  }

  /// Thêm thông báo mới vào danh sách
  void addNotification(AppNotification notification) {
    if (_currentUserId == null) return;
    // Không kiểm tra userId vì AppNotification không có userId, chỉ dựa vào dữ liệu từ API
    _notifications.add(notification);
    notifyListeners();
  }

  /// Làm mới danh sách tin nhắn
  Future<void> refreshMessages(
      int receiverId,
      int currentUserId,
      BuildContext context, {
        String receiverType = 'App\\Models\\User',
      }) async {
    await fetchMessages(receiverId, currentUserId, context, receiverType: receiverType);
  }

  /// Làm mới danh sách thông báo
  Future<void> refreshNotifications(int currentUserId, BuildContext context) async {
    await fetchNotifications(currentUserId, context);
  }

  /// Bắt đầu polling để kiểm tra tin nhắn và thông báo mới
  void startPolling(BuildContext context) {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentUserId != null) {
        fetchNotifications(_currentUserId!, context);
        if (_currentReceiverId != null && _currentReceiverType != null) {
          fetchMessages(_currentReceiverId!, _currentUserId!, context, receiverType: _currentReceiverType!);
        }
      }
    });
  }

  /// Dừng polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Xóa tất cả tin nhắn và trạng thái (không thông báo UI)
  void safeClearMessages() {
    _messages = [];
    _notifications = [];
    _error = null;
    _isLoading = false;
    _currentReceiverId = null;
    _currentReceiverType = null;
    _currentUserId = null;
    stopPolling();
  }

  /// Xóa tất cả tin nhắn và thông báo UI
  void clearMessages() {
    _messages = [];
    _notifications = [];
    _error = null;
    _isLoading = false;
    _currentReceiverId = null;
    _currentReceiverType = null;
    _currentUserId = null;
    stopPolling();
    notifyListeners();
  }
}