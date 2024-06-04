import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/core/dependency_injection/service_locator.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/domain/analyzer_use_case.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/presentation/bloc/analyzer_bloc.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/presentation/view/analyzer_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => AnalyzerBloc(getIt<AnalyzerUseCase>())..add(const AnalyzerEvent.started()),
        child: const AnalyzerView(),
      ),
    );
  }
}