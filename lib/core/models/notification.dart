class AppNotification {
  final int id; // ID của thông báo
  final String title;
  final String content;
  final DateTime createdAt;
  bool isRead; // Bỏ final để có thể thay đổi giá trị

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Lấy is_read từ users[0].pivot.is_read
    final isRead = json['users'] != null &&
        json['users'].isNotEmpty &&
        json['users'][0]['pivot'] != null
        ? json['users'][0]['pivot']['is_read'] == 1 ||
        json['users'][0]['pivot']['is_read'] == true
        : false;

    return AppNotification(
      id: json['id'] ?? 0,
      title: json['title'] ?? "Không có tiêu đề",
      content: json['content'] ?? "Không có nội dung",
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: isRead,
    );
  }
}