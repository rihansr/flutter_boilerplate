import 'package:boilerplate/shared/colors.dart';
import 'package:boilerplate/shared/strings.dart';
import 'package:flutter/material.dart';
import '../controllers/chat_viewmodel.dart';
import '../widgets/base_widget.dart';
import '../widgets/input_field_widget.dart';
import '../widgets/splitter_widget.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatViewModel>(
      model: ChatViewModel(),
      onInit: (controller) => controller.create(),
      builder: (context, controller, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Socket Chat'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Splitter.vertical(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                controller: controller.messageController,
                minLines: 1,
                maxLines: 5,
                hint: string(context).writeMessage,
              ),
              StreamBuilder(
                stream: controller.channel.stream,
                builder: (context, snapshot) {
                  return Text(snapshot.hasData ? '${snapshot.data}' : '');
                },
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.sendMessage,
          tooltip: 'Send message',
          child: Icon(
            Icons.send,
            color: ColorPalette.light().primaryLight,
          ),
        ),
      ),
    );
  }
}
