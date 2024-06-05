import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/presentation/view/analyzer_view.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/domain/chat_usecase.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/chat/data/model/chat_model.dart';
import '../../feature/chat/presentation/view/chat_view.dart';
import '../dependency_injection/service_locator.dart';

Handler analyzerHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
  const AnalyzerView(),
);

Handler chatHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    final chatModel = context?.settings?.arguments as ChatModel;
    return BlocProvider(
      create: (context) => ChatBloc(getIt<ChatUseCase>())..add(ChatEventStart(prompt: '', model: chatModel)),
      child: ChatView(model: chatModel,),
    );
  },
);
