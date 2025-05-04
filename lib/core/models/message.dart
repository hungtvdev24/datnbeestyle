class Message {
  final int id;
  final int senderId;
  final String senderType;
  final String? senderName;
  final int receiverId;
  final String receiverType;
  final String content;
  bool isRead; // Bỏ từ khóa `final`
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.senderType,
    this.senderName,
    required this.receiverId,
    required this.receiverType,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderType: json['sender_type'] ?? '',
      senderName: json['sender_name'],
      receiverId: json['receiver_id'] ?? 0,
      receiverType: json['receiver_type'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }

  String getFormattedTime() {
    return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Message(id: $id, senderId: $senderId, senderType: $senderType, receiverId: $receiverId, receiverType: $receiverType, content: $content, isRead: $isRead, createdAt: $createdAt)';
  }
}