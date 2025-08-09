import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constant.dart';
import '../theme/app_colors.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSendPressed;
  final VoidCallback onCancelReply;
  final ValueChanged<String>? onTextChanged;

  final Function(File) onFilePicked;
  final Function(File) onVideoPicked;

  const ChatInputField({
    super.key,
    required this.onSendPressed,
    required this.onCancelReply,
    this.onTextChanged,
    required this.onFilePicked,
    required this.onVideoPicked,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final chatTxtController = TextEditingController();

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      widget.onFilePicked(File(result.files.single.path!));
    }
  }

  Future<void> _recordVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      widget.onVideoPicked(File(video.path));
    }
  }

  @override
  void dispose() {
    chatTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: chatTxtController,
                        decoration: const InputDecoration(
                          hintText: "Type message...",
                          border: InputBorder.none,
                        ),
                        onChanged: widget.onTextChanged,
                      ),
                    ),
                    // Attach Document Icon
                    GestureDetector(
                      onTap: _pickDocument,
                      child: Icon(
                        Icons.attach_file,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withOpacity(0.64),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 3),

                    GestureDetector(
                      onTap: _recordVideo,
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withOpacity(0.64),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: AppColors.kPrimaryColor,
              child: IconButton(
                onPressed: () {
                  if (chatTxtController.text.trim().isNotEmpty) {
                    widget.onSendPressed(chatTxtController.text);
                    chatTxtController.clear();
                  }
                },
                icon: const Icon(Icons.send, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
