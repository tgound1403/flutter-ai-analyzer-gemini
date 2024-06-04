import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import 'message.dart';

part 'chat_model.freezed.dart';

part 'chat_model.g.dart';

@freezed
class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String id,
    required List<MessageModel> message,
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, Object?> json) => _$ChatModelFromJson(json);
}