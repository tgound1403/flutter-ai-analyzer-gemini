import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/core/services/firebase/firestore.dart';
import 'package:flutter_ai_analyzer_app/core/services/gemini_ai/gemini.dart';
import 'package:flutter_ai_analyzer_app/core/utils/enum/load_state.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/presentation/components/message_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/router/router.dart';
import '../../../../core/utils/logger.dart';
import '../../data/model/chat_model.dart';
import '../../data/model/message.dart';
import '../bloc/chat_bloc.dart';

class ChatView extends StatefulWidget {
  ChatView({required this.model, super.key});

  ChatModel model;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ChatBloc get _bloc => context.read<ChatBloc>();

  // String? chatResponseFromAI;
  // final List<MessageModel> _messageInChat = [];
  // bool _isLoading = false;
  final _controller = TextEditingController();

  @override
  void initState() {
    // _messageInChat.addAll(widget.model.messages!.toList());
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
              width: MediaQuery.sizeOf(context).width * .6,
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
  void chatWithAI() {
    _bloc.add(ChatEventStart(prompt: _controller.text, model: widget.model));
    _controller.clear();
  }

  //* endregion

  //* region UI
  Widget _buildMessagesSection() {
    return Expanded(
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final messages = state.model?.messages ?? [];
          return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageView(message: message);
              });
        },
      ),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return GestureDetector(
                    child: state.state.isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                    onTap: () => chatWithAI(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
//* endregion
}
