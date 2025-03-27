class AppNotification {
  final int id; // ID của user_notification
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0, // ID của user_notification
      title: json['title'] ?? "Không có tiêu đề", // Lấy trực tiếp từ json
      content: json['content'] ?? "Không có nội dung", // Lấy trực tiếp từ json
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['pivot']['is_read'] == 1 || json['pivot']['is_read'] == true,
    );
  }
}