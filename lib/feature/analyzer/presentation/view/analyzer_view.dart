import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_analyzer_app/core/common/style/border_radius_style.dart';
import 'package:flutter_ai_analyzer_app/core/common/style/padding_style.dart';
import 'package:flutter_ai_analyzer_app/core/services/gemini_ai/gemini.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/data/model/chat_model.dart';
import 'package:flutter_ai_analyzer_app/feature/chat/data/model/message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/router/route_path.dart';
import '../../../../core/router/router.dart';
import '../../../../core/services/firebase/firestore.dart';
import '../../../../core/utils/logger.dart';
import 'package:mime/mime.dart';

class AnalyzerView extends StatefulWidget {
  const AnalyzerView({super.key});

  @override
  State<AnalyzerView> createState() => _AnalyzerViewState();
}

class _AnalyzerViewState extends State<AnalyzerView> {
  final List<ChatModel> lsChat = [];
  late File? file;
  final _controller = TextEditingController();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    final chatRes = await Firestore.instance.readAllData('chats');
    for (var e in chatRes) {
      lsChat.add(ChatModel.fromJson(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: _controller.text.isNotEmpty ? const Text('AI Analyzer') : null,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: Drawer(
          child: _buildDrawerContent(),
        ),
        body: _buildBody(),
      ),
    );
  }

  //* region UI
  Widget _buildDrawerContent() {
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: AppPadding.styleLarge,
          child: Text(
            'Old stories',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const Gap(32),
        ListView.separated(
            shrinkWrap: true,
            itemBuilder: (_, idx) => InkWell(
                  onTap: () async => await openChat(lsChat[idx].id ?? ''),
                  child: ListTile(
                    title: MarkdownBody(
                      data: lsChat[idx].title ?? '',
                    ),
                  ),
                ),
            separatorBuilder: (_, idx) => const Divider(
                  thickness: 1,
                ),
            itemCount: lsChat.length)
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: AppPadding.styleLarge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWelcome(),
          _buildFileDisplay(),
          _buildTextField(),
          const Gap(16),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    if (_controller.text.isNotEmpty) {
      return const SizedBox.shrink();
    } else {
      return const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.android_rounded,
                size: 64,
                color: Colors.greenAccent,
              ),
              Gap(8),
              Text(
                'AI Analyzer',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ],
          ),
          Gap(128)
        ],
      );
    }
  }

  Widget _buildButton() {
    return _controller.text.isNotEmpty
        ? ElevatedButton(
            onPressed: () async => await goToChat(),
            child: const Text('Start chat'))
        : const SizedBox.shrink();
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 1))
          ]),
      child: GestureDetector(
        onTap: () async => await browseFile(),
        child: TextField(
          enabled: false,
          controller: _controller,
          style: Theme.of(context).textTheme.titleSmall,
          decoration: InputDecoration(
              hintText: 'Choose your file...',
              hintStyle: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
        ),
      ),
    );
  }

  Widget _buildFileDisplay() {
    if (_controller.text.isNotEmpty) {
      final mimeType = lookupMimeType(file!.path);
      final fileMime = mimeType?.substring(0, mimeType.indexOf('/'));
      return Container(
          padding: AppPadding.styleMedium,
          height: MediaQuery.sizeOf(context).height * .5,
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.styleMedium,
          ),
          child: fileMime == 'image'
              ? Image.file(file!)
              : Text(
                  'This is ${fileMime ?? ' '}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ));
    } else {
      return const SizedBox.shrink();
    }
  }

  //* endregion

  //* region ACTION
  Future<void> browseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = File(result.files.single.path!);
      final filePath = file!.path.toString();
      _controller.text =
          file!.path.substring(filePath.lastIndexOf('/') + 1, filePath.length);
      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Future<void> goToChat() async {
    // await Routes.router.navigateTo(context, RoutePath.chatView);
    final response = await GeminiAI.instance.generateFromSingleFile(file!, '');
    if (response?.isNotEmpty ?? false) {
      final title = await GeminiAI.instance.generateFromText(
          'Give me a short title with at most 10 words from this paragraph: $response, '
              'just give me plain text title back, not markdown format');
      List<int> imageBytes = file!.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      final mimeType = lookupMimeType(file!.path);
      final userMessage = MessageModel(message: base64Image, isUser: true, mimeType: mimeType);
      final systemMessage =
          MessageModel(message: response ?? '', isUser: false);
      final data = ChatModel(
          id: const Uuid().v4(),
          title: title ?? '',
          messages: [userMessage, systemMessage]);
      Firestore.instance.addData(data.toJson(), 'chats');
      Routes.router.navigateTo(context, RoutePath.chatView,
          routeSettings: RouteSettings(arguments: data));
    }
  }

  Future<void> openChat(String id) async {
    final res = await Firestore.instance.readSpecificData('chats', id);
    final model = ChatModel.fromJson(res);
    await Routes.router.navigateTo(context, RoutePath.chatView,
        routeSettings: RouteSettings(arguments: model));
  }
//*  endregion
}
