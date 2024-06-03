import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../utils/logger.dart';

class GeminiAI {
  static final instance = GeminiAI();
  static late GenerativeModel? model;
  final talker = Talker();

  static Future<void> initService() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<String?> generateFromText(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await model?.generateContent(content);
    talker.info(response?.text);
    return response?.text;
  }

  Future<String?> generateFromTextAndFile(List<File> files, String inputPrompt) async {
    final (firstImage, secondImage) = await (
        File('image0.jpg').readAsBytes(),
        File('image1.jpg').readAsBytes()
    ).wait;
    final imageParts = [
      DataPart('image/jpeg', firstImage),
      DataPart('image/jpeg', secondImage),
    ];
    final prompt = TextPart(inputPrompt);
    final response = await model?.generateContent([
      Content.multi([prompt, ...imageParts])
    ]);
    talker.info(response?.text);
    return response?.text;
  }

  Future<void> chat() async {
    // Initialize the chat
    final chat = model?.startChat(history: [
      Content.text('Hello, I have 2 dogs in my house.'),
      Content.model([TextPart('Great to meet you. What would you like to know?')])
    ]);
    var content = Content.text('How many paws are in my house?');
    var response = await chat?.sendMessage(content);
    talker.info(response?.text);
    Logger.i(response?.text);
  }
}