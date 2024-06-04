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
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      systemInstruction: Content.text(
          "You are an expert in narrating a story from the given data. "
          "For example, describe weather information and remind people to bring necessary items to deal with the weather,  "
          "interpret ECG data to support healthcare professionals in making decisions, etc. "
          "When you reply to me, you will break the answer into 2 sections, break into new paragraph after each section, section heading including: "
          "What is the given data about? and What are advices you can give from that data?"),
    );
  }

  Future<String?> generateFromText(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await model?.generateContent(content);
      talker.info(response?.text);
      return response?.text;
    } catch (e, st) {
      talker.error(e);
      talker.error(st);
    }
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

  Future<String?> chat({required List<Content>? history, required Content prompt}) async {
    // Initialize the chat
    try {
      final chat = model?.startChat(history: history);
      var response = (await chat?.sendMessage(prompt))?.text;
      talker.info(response);
      return response;
    } catch (e, st) {
      talker.error(e);
      talker.error(st);
    }
  }
}