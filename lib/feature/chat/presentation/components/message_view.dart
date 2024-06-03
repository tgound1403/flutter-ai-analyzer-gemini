import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/presentation/view/message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageView extends StatelessWidget {
  const MessageView({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: message.isUser ?
                Colors.blueGrey.shade50 :
                Colors.blueGrey.shade200,
                borderRadius: message.isUser ?
                const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                ) :
                const BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)
                )
            ),
            child: MarkdownBody(
              data: message.text,
            )
        ),
      ),
    );
  }
}
