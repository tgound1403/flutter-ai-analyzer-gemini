import 'package:flutter_ai_analyzer_app/feature/analyzer/data/analyzer_remote_ds.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/domain/analyzer_repository.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/domain/analyzer_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// import 'service_locator.config.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<AnalyzerUseCase>(AnalyzerUseCase(AnalyzerRepository(AnalyzerRemoteDataSource())));
}

