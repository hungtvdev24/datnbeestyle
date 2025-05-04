import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/api/auth_service.dart';
import '../../core/models/user.dart';
import '../../core/api/pusher_service.dart';
import '../../routes.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  String? _token;
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late PusherService _pusherService;
  late ChatProvider _chatProvider;
  int? _currentUserId;
  bool _isPusherInitialized = false;
  bool _isChatInitializing = true;
  final User _admin = User(
    id: 1, // Admin mặc định
    name: 'Admin',
    email: 'admin1@example.com',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authService = AuthService();
    authService.getToken().then((token) {
      if (token != null) {
        setState(() {
          _token = token;
        });
        // Khởi tạo nhắn tin và thông báo
        _initializeChat();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không tìm thấy token. Vui lòng đăng nhập lại.")),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi lấy token: $e")),
        );
      }
    });
  }

  Future<void> _initializeChat() async {
    final authService = AuthService();
    try {
      if (_token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy token. Vui lòng đăng nhập lại.")),
        );
        return;
      }

      final user = await authService.getUser();
      _currentUserId = user['user']['id'];
      if (_currentUserId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể lấy thông tin người dùng.")),
        );
        return;
      }

      // Tải thông báo và tin nhắn
      await _chatProvider.fetchNotifications(_currentUserId!, context);
      _pusherService = PusherService();
      await _pusherService.initPusher(_currentUserId!, _chatProvider);
      _isPusherInitialized = true;
      _pusherService.subscribeToChannel(_currentUserId!);
      await _chatProvider.fetchMessages(_admin.id, _currentUserId!, context,
          receiverType: 'App\\Models\\Admin');
      await _markMessagesAsRead();
      _chatProvider.startPolling(context);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khởi tạo: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChatInitializing = false;
        });
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    for (var message in _chatProvider.messages) {
      if (!message.isRead && message.receiverId == _currentUserId) {
        await _chatProvider.markAsRead(message.id);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
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
    if (content.isNotEmpty && _currentUserId != null) {
      _chatProvider.sendMessage(_admin.id, content, _currentUserId!, context,
          receiverType: 'App\\Models\\Admin');
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể gửi tin nhắn. Vui lòng thử lại.")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_isPusherInitialized) {
      _pusherService.unsubscribeFromChannel();
      _pusherService.disconnect();
    }
    _messageController.dispose();
    _scrollController.dispose();
    _chatProvider.stopPolling();
    _chatProvider.safeClearMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thông báo & Nhắn tin",
          style: TextStyle(
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
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Thông báo'),
            Tab(text: 'Nhắn tin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationTab(context),
          _buildChatTab(context),
        ],
      ),
    );
  }

  Widget _buildNotificationTab(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
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
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => provider.refreshNotifications(_currentUserId ?? 1, context),
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
        if (provider.notifications.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có thông báo nào.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.notifications.length,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
          itemBuilder: (context, index) {
            final notification = provider.notifications[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.white : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: notification.isRead
                      ? Colors.grey.shade300
                      : const Color(0xFFFCE4EC),
                  child: Icon(
                    Iconsax.notification,
                    color: notification.isRead ? Colors.grey : Colors.pink,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    notification.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Iconsax.share,
                        size: 20,
                        color: Colors.grey,
                      ),
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
                    await provider.markNotificationAsRead(notification.id);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatTab(BuildContext context) {
    if (_isChatInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentUserId == null) {
      return const Center(child: Text('Lỗi: Không thể tải thông tin người dùng'));
    }

    return Column(
      children: [
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
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
                          provider.refreshMessages(_admin.id, _currentUserId!, context,
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

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                reverse: true,
                itemCount: provider.messages.length,
                itemBuilder: (context, index) {
                  final message = provider.messages[provider.messages.length - 1 - index];
                  final isSent =
                      message.senderId == _currentUserId && message.senderType == 'App\\Models\\User';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Align(
                      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
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