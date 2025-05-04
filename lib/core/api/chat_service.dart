import '../api/api_client.dart';
import '../models/message.dart';
import '../models/notification.dart';

class ChatService {
  Future<List<Message>> fetchMessages(
      int receiverId, {
        String receiverType = 'App\\Models\\User',
      }) async {
    try {
      final response = await ApiClient.getMessages(
        receiverId,
        receiverType: receiverType,
      );
      final messages = response.map((json) => Message.fromJson(json)).toList();
      return messages;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage(
      int receiverId,
      String content, {
        String receiverType = 'App\\Models\\User',
      }) async {
    try {
      await ApiClient.sendMessage(receiverId, content, receiverType: receiverType);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int messageId) async {
    try {
      await ApiClient.markMessageAsRead(messageId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications(int userId) async {
    try {
      final response = await ApiClient.getNotifications(userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await ApiClient.markNotificationAsRead(notificationId);
    } catch (e) {
      rethrow;
    }
  }
}