import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/api/auth_service.dart';
import '../../core/models/user.dart';
import '../../core/api/pusher_service.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;

  const ChatScreen({super.key, required this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late PusherService _pusherService;
  late ChatProvider _chatProvider;
  String? _token;
  int? _currentUserId;
  bool _isPusherInitialized = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    print("Đã vào ChatScreen với receiver: ${widget.receiver.name}, receiverId: ${widget.receiver.id}");
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _initializeUserAndPusher();
  }

  Future<void> _initializeUserAndPusher() async {
    final authService = AuthService();
    try {
      _token = await authService.getToken();
      print('Token: $_token');
      if (_token == null) {
        print('Không tìm thấy token');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy token. Vui lòng đăng nhập lại.")),
        );
        Navigator.pop(context);
        return;
      }

      final user = await authService.getUser();
      print('User data: $user');
      _currentUserId = user['user']['id']; // Sửa để lấy từ user[user][id]
      if (_currentUserId == null) {
        print('Không thể lấy ID người dùng');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể lấy thông tin người dùng.")),
        );
        Navigator.pop(context);
        return;
      }
      print('Current User ID: $_currentUserId');

      _pusherService = PusherService();
      await _pusherService.initPusher(_currentUserId!, _chatProvider);
      _isPusherInitialized = true;
      _pusherService.subscribeToChannel(_currentUserId!);
      await _chatProvider.fetchMessages(widget.receiver.id, _currentUserId!, context,
          receiverType: 'App\\Models\\Admin');
      await _markMessagesAsRead();
      _chatProvider.startPolling(context); // Bắt đầu polling
      _scrollToBottom();
    } catch (e) {
      print("Lỗi khởi tạo trong ChatScreen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khởi tạo: $e")),
      );
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    for (var message in _chatProvider.messages) {
      if (!message.isRead && message.receiverId == _currentUserId) {
        await _chatProvider.markAsRead(message.id);
      }
    }
  }

  @override
  void dispose() {
    if (_isPusherInitialized) {
      print('Ngắt kết nối Pusher');
      _pusherService.unsubscribeFromChannel();
      _pusherService.disconnect();
    }
    _messageController.dispose();
    _scrollController.dispose();
    _chatProvider.stopPolling(); // Dừng polling
    _chatProvider.safeClearMessages(); // Sử dụng safeClearMessages để tránh lỗi widget tree
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      print('Cuộn xuống cuối danh sách tin nhắn');
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      print('ScrollController chưa sẵn sàng, thử lại sau khi build');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          print('Cuộn xuống cuối danh sách tin nhắn sau khi build');
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      print('Gửi tin nhắn: $content');
      _chatProvider.sendMessage(widget.receiver.id, content, _currentUserId!, context,
          receiverType: 'App\\Models\\Admin');
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      print('Tin nhắn rỗng, không gửi');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      print('Đang khởi tạo, hiển thị loading');
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_token == null || _currentUserId == null) {
      print('Token hoặc CurrentUserId là null, hiển thị lỗi');
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Lỗi: Không thể tải thông tin người dùng')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Chat với ${widget.receiver.name}",
          style: const TextStyle(
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
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () {
            print('Nhấn nút quay lại');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.black),
            onPressed: () {
              print('Nhấn nút làm mới tin nhắn');
              _chatProvider.refreshMessages(widget.receiver.id, _currentUserId!, context,
                  receiverType: 'App\\Models\\Admin');
              _scrollToBottom();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                print(
                    'Consumer rebuild - isLoading: ${provider.isLoading}, messages: ${provider.messages.length}, error: ${provider.error}');

                if (provider.isLoading && provider.messages.isEmpty) {
                  print('Hiển thị CircularProgressIndicator vì đang tải lần đầu');
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  print('Hiển thị lỗi: ${provider.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lỗi: ${provider.error}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            print('Nhấn nút Thử lại');
                            provider.refreshMessages(widget.receiver.id, _currentUserId!, context,
                                receiverType: 'App\\Models\\Admin');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: const BorderSide(color: Colors.black),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Thử lại",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.messages.isEmpty) {
                  print('Hiển thị thông báo "Chưa có tin nhắn nào"');
                  return const Center(
                    child: Text(
                      'Chưa có tin nhắn nào.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  );
                }

                print('Hiển thị danh sách tin nhắn với số lượng: ${provider.messages.length}');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[provider.messages.length - 1 - index];
                    final isSent =
                        message.senderId == _currentUserId && message.senderType == 'App\\Models\\User';
                    print('Hiển thị tin nhắn $index: ${message.content}, isSent: $isSent');
                    return Align(
                      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSent ? const Color(0xFF0084FF) : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (message.senderName != null)
                              Text(
                                message.senderName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSent ? Colors.white70 : Colors.grey.shade600,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              message.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSent ? Colors.white : Colors.black,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.getFormattedTime(),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSent ? Colors.white70 : Colors.grey.shade600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            if (isSent && message.isRead)
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Colors.white70,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Iconsax.send_1, color: Color(0xFF0084FF)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}