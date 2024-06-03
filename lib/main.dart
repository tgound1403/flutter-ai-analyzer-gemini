import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/core/services/gemini_ai/gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

void main() async {
  await initApp();
  runApp(const MyApp());
}

Future<void> initApp() async {
  await dotenv.load(fileName: ".env");
  await GeminiAI.initService();
}
