import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/core/dependency_injection/service_locator.dart';
import 'package:flutter_ai_analyzer_app/core/services/gemini_ai/gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/router/router.dart';
import 'core/services/firebase/firebase_options.dart';
import 'core/services/firebase/firestore.dart';

void main() async {
  await initApp();
  runApp(const MyApp());
}

Future<void> initApp() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform,);
  await GeminiAI.initService();
  await Firestore.init();
  Routes.configureRoutes();
  setupDependencies();
}
