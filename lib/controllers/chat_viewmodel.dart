import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatViewModel extends ChangeNotifier {
  late WebSocketChannel channel;

  final TextEditingController messageController = TextEditingController();

  create() {
    webSocket();
  }

  webSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://socketsbay.com/wss/v2/1/demo/'),
    );
    // Use this to listen while strem is not used in the view
    /* channel.stream.listen((message) {
      debug.print(message);
    }); */
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      channel.sink.add(messageController.text);
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    super.dispose();
  }
}
