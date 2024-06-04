import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ai_analyzer_app/feature/analyzer/domain/analyzer_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/common/models/error_state.dart';
import '../../../../core/router/route_path.dart';
import '../../../../core/router/router.dart';
import '../../../../core/utils/logger.dart';
import '../../../chat/data/model/chat_model.dart';

part 'analyzer_event.dart';

part 'analyzer_state.dart';

part 'analyzer_bloc.freezed.dart';

class AnalyzerBloc extends Bloc<AnalyzerEvent, AnalyzerState> {
  final AnalyzerUseCase _useCase;

  AnalyzerBloc(this._useCase) : super(const _Initial()) {
    on<AnalyzerEvent>((event, emit) {
      return event.when<void>(
        started: () async {
          add(const AnalyzerEvent.loading());

          final chats = await _useCase.fetchOldChats();
          chats.fold(
            (l) => emit(AnalyzerState.error(l)),
            (r) => _lsChat = r,
          );
          Logger.d('Chat size: ${_lsChat?.length}');
          emit(AnalyzerState.data(_lsChat));
        },
        createNew: (context, file) async {
          add(const AnalyzerEvent.loading());

          final chat = await _useCase.startChatSection(file: file);
          chat.fold(
            (l) => emit(AnalyzerState.error(l)),
            (r) => _openChat(context, model: r),
          );
          emit(AnalyzerState.data(_lsChat));
        },
        loading: () => emit(const AnalyzerState.loading()),
        error: (error) => emit(AnalyzerState.error(error)),
        data: (chats) => emit(AnalyzerState.data(chats)),
      );
    });
  }

  List<ChatModel>? _lsChat;

  void _openChat(BuildContext context, {ChatModel? model}) {
    Routes.router.navigateTo(
      context,
      RoutePath.chatView,
      routeSettings: RouteSettings(
        arguments: model,
      ),
    );
  }

  void openChat(BuildContext context, String id) async {
    final res = await _useCase.openOldChat(id: id);
    res.fold(Left.new, (r) {
      Routes.router.navigateTo(
        context,
        RoutePath.chatView,
        routeSettings: RouteSettings(
          arguments: r,
        ),
      );
    });
  }
}
