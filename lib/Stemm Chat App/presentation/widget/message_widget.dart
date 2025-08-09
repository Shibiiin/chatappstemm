import 'dart:io';
import 'dart:math';

import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_Toast.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_print.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_colors.dart';

class MessageWidget extends StatefulWidget {
  final Map<String, dynamic> messageData;

  const MessageWidget({Key? key, required this.messageData}) : super(key: key);

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  Widget _buildMessageContent() {
    final String? type = widget.messageData['type'] as String?;

    switch (type) {
      case 'video':
        return _VideoMessageContent(
          thumbnailUrl: widget.messageData['thumbnailUrl'],
          videoUrl: widget.messageData['url'],
        );
      case 'file':
        return _FileMessageContent(
          fileName: widget.messageData['fileName'],
          fileSize: widget.messageData['fileSize'],
          fileUrl: widget.messageData['url'],
        );
      case 'text':
      default:
        return Text(
          widget.messageData['message'] ?? '',
          style: const TextStyle(color: AppColors.white, fontSize: 16),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSender =
        widget.messageData['senderId'] ==
        FirebaseAuth.instance.currentUser!.uid;
    final DateTime timestamp =
        (widget.messageData['timestamp'] as Timestamp? ?? Timestamp.now())
            .toDate();
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          if (!isSender)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(radius: 15, child: Icon(Icons.person)),
            ),
          Column(
            crossAxisAlignment: isSender
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
                  color: isSender ? AppColors.green : AppColors.chatBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildMessageContent(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 5, right: 5),
                child: Text(
                  DateFormat('hh:mm a').format(timestamp),
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

class _VideoMessageContent extends StatelessWidget {
  final String? thumbnailUrl;
  final String? videoUrl;

  const _VideoMessageContent({this.thumbnailUrl, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        alertPrint("Play video at: $videoUrl");
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(thumbnailUrl!),
            )
          else
            Container(
              height: 200,
              width: 200,
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.videocam_off, color: Colors.white),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

class _FileMessageContent extends StatelessWidget {
  final String? fileName;
  final int? fileSize;
  final String? fileUrl;

  const _FileMessageContent({this.fileName, this.fileSize, this.fileUrl});

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (fileUrl == null) return;
        try {
          final response = await http.get(Uri.parse(fileUrl!));
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        } catch (e) {
          customToastMsg("Could not open file: $e");
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.article, color: Colors.white, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? 'Document',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (fileSize != null)
                    Text(
                      _formatBytes(fileSize!, 2),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
