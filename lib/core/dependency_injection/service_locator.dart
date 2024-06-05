import 'package:flutter_ai_analyzer_app/feature/analyzer/data/analyzer_remote_ds.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/domain/analyzer_repository.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/domain/analyzer_use_case.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/data/ds/chat_remote_data_source.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/domain/chat_repository.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/domain/chat_usecase.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<AnalyzerUseCase>(AnalyzerUseCase(AnalyzerRepository(AnalyzerRemoteDataSource())));
  getIt.registerSingleton<ChatUseCase>(ChatUseCase(ChatRepository(ChatRemoteDataSource())));
}

