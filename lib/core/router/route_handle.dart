import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/presentation/view/analyzer_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/chat/presentation/view/chat_view.dart';

Handler analyzerHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
  const AnalyzerView(),
);

Handler chatHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    // return BlocProvider(
      // create: (context) =>
      // SignInBloc(getIt<AuthUseCase>())..add(SignInInitRequested()),
      // child: const ChatView(),
    // );
  },
);
