import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/presentation/view/chat_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatView(),
    );
  }
}