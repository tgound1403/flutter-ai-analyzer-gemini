import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_ai_analyzer_app/core/common/models/error_state.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/data/model/chat_model.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/firebase/firestore.dart';
import '../../../core/services/gemini_ai/gemini.dart';
import 'package:mime/mime.dart';

import '../../chat/data/model/message.dart';

class AnalyzerRemoteDataSource {
  final talker = Talker();

  Future<Either<ErrorState,List<ChatModel>>> fetchOldChats() async {
    try {
      final chatRes = await Firestore.instance.readAllData('chats');
      final result = <ChatModel>[];
      for (final chat in chatRes) {
        result.add(ChatModel.fromJson(chat));
      }
      return Right(result);
    } catch (e, st) {
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }

  Future<Either<ErrorState,ChatModel>> startChatSection(File? file) async {
    try {
      final response = await GeminiAI.instance.generateFromSingleFile(file!);
      if (response?.isNotEmpty ?? false) {
        final title = await GeminiAI.instance.generateFromText(
            'Give me a short title with at most 10 words from this paragraph: $response, '
            'just give me plain text title back, not markdown format');
        List<int> imageBytes = file.readAsBytesSync();
        String base64Image = base64Encode(imageBytes);
        final mimeType = lookupMimeType(file.path);
        final userMessage = MessageModel(message: base64Image, isUser: true, mimeType: mimeType);
        final systemMessage = MessageModel(message: response ?? '', isUser: false);
        final data = ChatModel(
            id: const Uuid().v4(),
            title: title ?? '',
            messages: [userMessage, systemMessage]);
        await Firestore.instance.addData(data.toJson(), 'chats');
        return Right(data);
      }
      return Right(ChatModel(id: null, title: null, messages: null));
    } catch (e, st) {
      talker.error(e);
      talker.error(st);
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }

  Future<Either<ErrorState,ChatModel>> openOldChat(String id, ) async {
    try {
      final res = await Firestore.instance.readSpecificData('chats', id);
      final model = ChatModel.fromJson(res);
      return Right(model);
    } catch (e, st) {
      talker.error(e);
      talker.error(st);
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }

  Future<Either<ErrorState, bool>> deleteChat(String id) async {
    try {
      final res = await Firestore.instance.deleteSpecificData('chats', id);
      return Right(res);
    } catch (e, st) {
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }
}
