import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

class MessageWidget extends StatefulWidget {
  final String messageText;
  final DateTime timestamp;
  final bool isSender;
  final String name;
  final Function(String messageId) onLongPress;
  final bool isSelected;
  final Function() onTap;

  const MessageWidget({
    Key? key,

    required this.messageText,
    required this.timestamp,
    required this.isSender,
    required this.name,
    required this.onLongPress,
    required this.isSelected,
    required this.onTap,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: widget.isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          if (!widget.isSender)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(child: Icon(Icons.person), radius: 15),
            ),
          Column(
            crossAxisAlignment: widget.isSender
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: w * 0.75),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: widget.isSender
                      ? AppColors.green
                      : AppColors.chatBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.messageText,
                  style: const TextStyle(color: AppColors.white, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 5, right: 5),
                child: Text(
                  DateFormat('hh:mm a').format(widget.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
