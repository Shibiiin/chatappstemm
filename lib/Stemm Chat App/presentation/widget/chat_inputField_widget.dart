import 'package:flutter/material.dart';

import '../../../constant.dart';
import '../theme/app_colors.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSendPressed;
  final VoidCallback onCancelReply;
  final ValueChanged<String>? onTextChanged;

  const ChatInputField({
    super.key,
    required this.onSendPressed,
    required this.onCancelReply,
    this.onTextChanged,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final chatTxtController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    chatTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final controller = Provider.of<ChatController>(context);

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
            GestureDetector(
              onTap: () {},
              child: Icon(Icons.mic, color: AppColors.kPrimaryColor),
            ),
            const SizedBox(width: kDefaultPadding),
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
                    Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(0.64),
                    ),
                    const SizedBox(width: kDefaultPadding / 2),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: chatTxtController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Type message...",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (widget.onTextChanged != null) {
                            widget.onTextChanged!(value);
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.attach_file,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withOpacity(0.64),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(0.64),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              child: IconButton(
                onPressed: () async {
                  widget.onSendPressed(chatTxtController.text);
                  chatTxtController.clear();
                  if (widget.onTextChanged != null) {
                    widget.onTextChanged!("");
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
