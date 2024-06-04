import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:mime/mime.dart';

import '../../utils/logger.dart';

class GeminiAI {
  static final instance = GeminiAI();
  static late GenerativeModel? model;
  final talker = Talker();

  static Future<void> initService() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(
          "You are an expert in narrating a story from the given data. "
          "For example, describe weather information and remind people to bring necessary items to deal with the weather,  "
          "interpret ECG data to support healthcare professionals in making decisions, etc. "
          "When you reply to me, you will break the answer into 3 sections including: "
          "What is the given data about?, What subject does it come from? and What are advices you can give from that data?"),
    );
  }

  Future<String?> generateFromText(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await model?.generateContent(content);
    talker.info(response?.text);
    return response?.text;
  }

  Future<String?> generateFromSingleFile(File file, String? inputPrompt) async {
    try {
      final image = await file.readAsBytes();
      // Gemini support img, csv
      // not support pdf
      final mimeType = lookupMimeType(file.path);
      talker.info(mimeType.toString());
      final filePart = DataPart(mimeType!, image);
      final prompt = TextPart(inputPrompt ?? '');
      final response = await model?.generateContent([
        Content.multi([prompt, filePart])
      ]);
      talker.info(response?.text);
      return response?.text;
    } on Exception catch (e, st) {
      talker.error(e);
      talker.error(st);
      return null;
    }
  }

  Future<String?> generateFromTextAndFiles(
      List<File> files, String inputPrompt) async {
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