part of 'chat_bloc.dart';
abstract class ChatEvent {}

class ChatEventStart extends ChatEvent {
  ChatEventStart({required this.prompt, required this.model});
  final ChatModel model;
  final String prompt;
}