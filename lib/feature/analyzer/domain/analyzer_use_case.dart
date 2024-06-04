import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/domain/analyzer_repository.dart';

import '../../../core/common/models/error_state.dart';
import '../../chat/data/model/chat_model.dart';

class AnalyzerUseCase {
  AnalyzerUseCase(this._repo);
  final AnalyzerRepository _repo;

  Future<Either<ErrorState, List<ChatModel>>> fetchOldChats() => _repo.fetchOldChats();

  Future<Either<ErrorState, ChatModel>> startChatSection({required File? file}) => _repo.startChatSection(file: file);

  Future<Either<ErrorState, ChatModel>> openOldChat({required String id}) => _repo.openOldChat(id: id);
}