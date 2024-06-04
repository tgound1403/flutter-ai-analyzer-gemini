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
          title: const Text('AI Analyzer'),
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
            separatorBuilder: (_, idx) => const Divider(thickness: 1,),
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
          _buildImage(),
          const Gap(16),
          _buildTextField(),
          const Gap(16),
          ElevatedButton(
              onPressed: () async => await goToChat(),
              child: const Text('Start chat'))
        ],
      ),
    );
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

  Widget _buildImage() {
    if (_controller.text.isNotEmpty) {
      return Container(
          padding: AppPadding.styleMedium,
          height: MediaQuery.sizeOf(context).height * .5,
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.styleMedium,
          ),
          child: Image.file(file!));
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
      _controller.text = file!.path.substring(filePath.lastIndexOf('/') + 1, filePath.length);
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
          'Give me a short title with at most 10 words from this paragraph: $response, just give me plain text title back, not markdown format'
      );
      final userMessage  = MessageModel(message: _controller.text, isUser: true);
      final systemMessage = MessageModel(message: response ?? '', isUser: false);
      final data = ChatModel(id: const Uuid().v4(), title: title ?? '', messages: [userMessage, systemMessage] );
      Firestore.instance.addData(data.toJson(), 'chats');
      Routes.router.navigateTo(context, RoutePath.chatView, routeSettings: RouteSettings(arguments: data));
    }
  }

  Future<void> openChat(String id) async {
    final res = await Firestore.instance.readSpecificData('chats', id);
      final model = ChatModel.fromJson(res);
      await Routes.router.navigateTo(context, RoutePath.chatView, routeSettings: RouteSettings(arguments: model));
  }
  //*  endregion
}
