import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../providers/chat_provider.dart';
import '../models/message.dart';
import 'dart:convert'; // Thêm để parse JSON

class PusherService {
  late PusherChannelsFlutter pusher;
  late ChatProvider chatProvider;
  int? userId;

  PusherService() {
    pusher = PusherChannelsFlutter();
  }

  Future<void> initPusher(int userId, ChatProvider provider) async {
    this.userId = userId;
    this.chatProvider = provider;

    try {
      await pusher.init(
        apiKey: '425a7651a0c89120c672',
        cluster: 'ap1',
        onConnectionStateChange: (String currentState, String previousState) {
          print('Pusher Connection: $currentState (trước đó: $previousState)');
        },
        onError: (String message, int? code, dynamic error) {
          print('Pusher Error: $message, Code: $code, Error: $error');
        },
        onSubscriptionSucceeded: (String channelName, dynamic data) {
          print('Pusher Subscription Succeeded: Channel $channelName, Data: $data');
        },
        onEvent: (PusherEvent event) {
          if (event.eventName == 'message.sent') {
            print('Pusher Event: ${event.eventName}, Raw Data: ${event.data}');
            // Parse dữ liệu từ event.data (là một chuỗi JSON)
            final data = jsonDecode(event.data);
            final messageData = data['message'];
            print('Parsed Message Data: $messageData');
            final message = Message.fromJson(messageData);
            chatProvider.addMessage(message);
          }
        },
      );
      await pusher.connect();
      print('Pusher khởi tạo thành công cho userId: $userId');
    } catch (e) {
      print('Lỗi khởi tạo Pusher: $e');
      rethrow;
    }
  }

  void subscribeToChannel(int userId) {
    pusher.subscribe(channelName: 'chat.$userId');
    print('Đã subscribe vào channel: chat.$userId');
  }

  void unsubscribeFromChannel() {
    if (userId != null) {
      pusher.unsubscribe(channelName: 'chat.$userId');
      print('Đã unsubscribe khỏi channel: chat.$userId');
    }
  }

  void disconnect() {
    pusher.disconnect();
    print('Pusher đã ngắt kết nối');
  }
}