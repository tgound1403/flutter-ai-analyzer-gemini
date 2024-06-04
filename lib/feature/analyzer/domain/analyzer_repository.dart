import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_ai_analyzer_app/core/common/models/error_state.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/data/analyzer_remote_ds.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/data/model/chat_model.dart';

class AnalyzerRepository {
  AnalyzerRepository(this._remoteDS);
  final AnalyzerRemoteDataSource _remoteDS;

  Future<Either<ErrorState, List<ChatModel>>> fetchOldChats() async {
    final result = await _remoteDS.fetchOldChats();
    return result.fold(Left.new, Right.new);
  }

  Future<Either<ErrorState, ChatModel>> startChatSection({required File? file}) async {
    final result = await _remoteDS.startChatSection(file);
    return result.fold(Left.new, Right.new);
  }

  Future<Either<ErrorState, ChatModel>> openOldChat({required String id}) async {
    final result = await _remoteDS.openOldChat(id);
    return result.fold(Left.new, Right.new);
  }
}