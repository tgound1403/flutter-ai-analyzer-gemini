import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'message.freezed.dart';

part 'message.g.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String message,
    required bool isUser,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, Object?> json) => _$MessageModelFromJson(json);
}
