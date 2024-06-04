import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/core/common/style/padding_style.dart';
import 'package:flutter_ai_analyzer_app/core/services/firebase/firestore.dart';
import 'package:flutter_ai_analyzer_app/core/services/gemini_ai/gemini.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/presentation/components/message_view.dart';
import 'package:gap/gap.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/router/router.dart';
import '../../../../core/utils/logger.dart';
import '../../data/model/chat_model.dart';
import '../../data/model/message.dart';

class ChatView extends StatefulWidget {
  ChatView({required this.model, super.key});

  ChatModel model;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String? response;
  final List<MessageModel> _messages = [];
  bool _isLoading = false;
  final _controller = TextEditingController();

  @override
  void initState() {
    _messages.addAll(widget.model.messages!.toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Routes.router.pop(context),
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        centerTitle: false,
        elevation: 1,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.android),
            const Gap(12),
            SizedBox(
              width: MediaQuery.sizeOf(context).width *.6,
              child: Text(
                widget.model.title?.replaceAll('#', '') ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [_buildMessagesSection(), _buildChatSection()],
      ),
    );
  }

  //*region ACTION
  Future<void> askAI(String question) async {
    List<Content>? history = [];
    try {
      if (_controller.text.isNotEmpty) {
        final message = MessageModel(message: _controller.text, isUser: true);
        _messages.add(message);
        _isLoading = true;
      }

      for (final message in widget.model.messages!) {
        if (message.isUser ?? false) {
          history.add(Content('user', [TextPart(message.message!)]));
        } else {
          history.add(Content('model', [TextPart(message.message!)]));
        }
      }

      response = await GeminiAI.instance.chat(prompt: Content.text(_controller.text), history: history) ?? "";

      setState(() {
        final aiRes = MessageModel(message: response ?? "", isUser: false);
        _messages.add(aiRes);
        widget.model.messages = _messages;
        Firestore.instance.modifyData('chats', widget.model.id!, widget.model.toJson());
        _isLoading = false;
      });

      _controller.clear();
    } catch (e) {
      Logger.e("Error : $e");
    }
  }

  //* endregion

  //* region UI
  Widget _buildMessagesSection() {
    return Expanded(
      child: ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return MessageView(message: message);
          }),
    );
  }

  Widget _buildChatSection() {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 32, top: 16.0, left: 16.0, right: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3))
            ]),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: Theme.of(context).textTheme.titleSmall,
                decoration: InputDecoration(
                    hintText: 'Write your message',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
              ),
            ),
            const Gap(8),
            _isLoading
                ? Padding(
                    padding: AppPadding.styleMedium,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      child: const Icon(Icons.send),
                      onTap: () => askAI(_controller.text),
                    ),
                  )
          ],
        ),
      ),
    );
  }
//* endregion
}
