import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/core/services/gemini_ai/gemini.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/presentation/components/message_view.dart';

import '../../../../core/utils/logger.dart';
import 'message.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String? response;
  final List<Message> _messages = [];
  bool _isLoading = false;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.android),
            const SizedBox(width: 12,),
            Text('AI Analyzer', style: Theme.of(context).textTheme.titleLarge,)
          ],
        ),
      ),
      body: Column(
        children: [
          _buildMessagesSection(),
          _buildChatSection()
        ],
      ),
    );
  }

  //*region ACTION
  Future<void> askAI(String question) async {
    try{
      if(_controller.text.isNotEmpty){
        _messages.add(Message(text: _controller.text, isUser: true));
        _isLoading = true;
      }

      response = await GeminiAI.instance.generateFromText(question) ?? "";

      setState(() {
        _messages.add(Message(text: response ?? "", isUser: false));
        _isLoading = false;
      });

      _controller.clear();
    }
    catch(e){
      Logger.e("Error : $e");
    }
    setState(() {});
  }
  //* endregion

  //* region UI
  Widget _buildMessagesSection() {
    return Expanded(
      child: ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (context, index){
            final message = _messages[index];
            return MessageView(message: message);
          }
      ),
    );
  }

  Widget _buildChatSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32,top: 16.0, left: 16.0, right: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3)
              )
            ]
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: Theme.of(context).textTheme.titleSmall,
                decoration: InputDecoration(
                    hintText: 'Write your message',
                    hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.grey
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20)
                ),
              ),
            ),
            SizedBox(width: 8,),
            _isLoading ?
            Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            ) :
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                child: Icon(Icons.send),
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
