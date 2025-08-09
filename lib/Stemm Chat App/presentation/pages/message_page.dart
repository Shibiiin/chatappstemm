import 'dart:io';

import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_print.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../constant.dart';
import '../manager/chat_Controller.dart';
import '../theme/app_colors.dart';
import '../widget/chat_inputField_widget.dart';
import '../widget/message_widget.dart';

class MessagesScreen extends StatefulWidget {
  final String id;
  final String name;

  const MessagesScreen({Key? key, required this.id, required this.name})
    : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // This function is correct.
  void handleFilePicked(File file, {bool isVideo = false}) {
    final chatController = Provider.of<ChatController>(context, listen: false);
    chatController.sendMediaMessage(
      file: file,
      receiverId: widget.id,
      receiverName: widget.name,
      type: isVideo ? 'video' : 'file',
    );
  }

  @override
  void initState() {
    super.initState();
    // This is fine.
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: buildAppBar(context, widget.name, MediaQuery.of(context).size),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatController.getMessages(widget.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    errorPrint("Error on message page ${snapshot.error}");
                    return const Center(
                      child: Text('No messages yet. Say hi!'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Say hi!'),
                    );
                  }
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageDoc = messages[index];
                      final messageData =
                          messageDoc.data() as Map<String, dynamic>;

                      // --- THIS IS THE CORRECTED CODE ---
                      // Pass the entire data map to the MessageWidget.
                      // The widget itself will figure out what to display.
                      return MessageWidget(messageData: messageData);
                      // --- END OF CORRECTION ---
                    },
                  );
                },
              ),
            ),
            // This ChatInputField implementation is correct.
            ChatInputField(
              onSendPressed: (message) async {
                if (message.trim().isNotEmpty) {
                  await chatController.sendMessage(
                    receiverId: widget.id,
                    receiverName: widget.name,
                    messageData: {'type': 'text', 'message': message.trim()},
                  );
                }
              },
              onCancelReply: () {},
              onFilePicked: (File file) {
                handleFilePicked(file, isVideo: false);
              },
              onVideoPicked: (File file) {
                handleFilePicked(file, isVideo: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  // This buildAppBar function is correct.
  PreferredSizeWidget buildAppBar(
    BuildContext context,
    String title,
    Size size,
  ) {
    return PreferredSize(
      preferredSize: Size.fromHeight(size.height * 0.09),
      child: AppBar(
        elevation: 0,
        backgroundColor: AppColors.green,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            BackButton(
              color: AppColors.white,
              onPressed: () {
                context.pop();
              },
            ),
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: kDefaultPadding * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Row(
            children: [
              Icon(Icons.video_call_outlined, color: AppColors.white),
              SizedBox(width: 15),
              Icon(Icons.call, color: AppColors.white),
              SizedBox(width: 15),
              Icon(Icons.more_vert, color: AppColors.white),
              SizedBox(width: 15),
            ],
          ),
        ],
      ),
    );
  }
}
