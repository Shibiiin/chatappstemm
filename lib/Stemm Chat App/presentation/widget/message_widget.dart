import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MessageWidget extends StatefulWidget {
  final bool isSender;
  final Function(String messageId) onLongPress;
  final bool isSelected;
  final Function() onTap;
  final String name;

  const MessageWidget({
    Key? key,

    required this.isSender,
    required this.onLongPress,
    required this.isSelected,
    required this.onTap,

    required this.name,
  });

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool isExpanded = false;
  bool isShowMessage = false;
  bool showOverlay = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTap: () {},
      onLongPress: () {},
      child: Row(
        mainAxisAlignment: widget.isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          if (!widget.isSender)
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/user_2.png'),
                radius: 15,
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicWidth(
                child: Container(
                  constraints: BoxConstraints(maxWidth: w * 0.7),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10.0,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // Rectangle shape
                    color: widget.isSelected
                        ? Colors.red
                        : (widget.isSender
                              ? AppColors.green
                              : AppColors.chatBlack),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Message Content
                      Text(
                        "displayText",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                        maxLines: isExpanded ? null : 15,
                      ),

                      /// Timestamp at Right End Below the Message
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Row(
                            mainAxisAlignment: widget.isSender
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.end,
                            children: [
                              Text(
                                "Time stamp",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 5),

                              const Icon(
                                Icons.done,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
