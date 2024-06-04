import 'package:fluro/fluro.dart';
import 'package:flutter_ai_analyzer_app/core/router/route_handle.dart';
import 'package:flutter_ai_analyzer_app/core/router/route_path.dart';

class Routes {
  Routes();

  static final router = FluroRouter();

  static void configureRoutes() {
    _setRouter(RoutePath.analyzerView, handler: analyzerHandler);

    _setRouter(RoutePath.chatView, handler: chatHandler);
  }

  static void _setRouter(
      String path, {
        required Handler handler,
        TransitionType? transitionType,
      }) {
    transitionType ??= TransitionType.cupertino;
    router.define(path, handler: handler, transitionType: transitionType);
  }
}
