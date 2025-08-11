import 'dart:io';
import 'dart:math';

import 'package:chatappstemm/Stemm%20Chat%20App/presentation/manager/chat_Controller.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_Toast.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_print.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';

class MessageWidget extends StatefulWidget {
  final Map<String, dynamic> messageData;

  const MessageWidget({Key? key, required this.messageData}) : super(key: key);

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  Widget _buildMessageContent() {
    final String senderId = widget.messageData['senderId'] ?? '';
    final String? type = widget.messageData['type'] as String?;

    switch (type) {
      case 'video':
        return _VideoMessageContent(
          thumbnailUrl: widget.messageData['thumbnailUrl'],
          videoUrl: widget.messageData['url'],
          senderId: senderId,
        );
      case 'file':
        return _FileMessageContent(
          fileName: widget.messageData['fileName'],
          fileSize: widget.messageData['fileSize'],
          fileUrl: widget.messageData['url'],
          senderId: senderId,
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
                child: Column(
                  crossAxisAlignment: isSender
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.end,
                  mainAxisAlignment: isSender
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    _buildMessageContent(),
                    Text(
                      textAlign: isSender ? TextAlign.end : TextAlign.start,
                      DateFormat('hh:mm a').format(timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoMessageContent extends StatefulWidget {
  final String? thumbnailUrl;
  final String? videoUrl;
  final String senderId;
  final String? uploadKey;

  const _VideoMessageContent({
    this.thumbnailUrl,
    this.videoUrl,
    required this.senderId,
    this.uploadKey,
  });

  @override
  State<_VideoMessageContent> createState() => _VideoMessageContentState();
}

class _VideoMessageContentState extends State<_VideoMessageContent> {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String _localVideoPath = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfVideoExists();
    });
  }

  Future<void> _checkIfVideoExists() async {
    final controller = Provider.of<ChatController>(context, listen: false);
    final downloadPath = await controller.getDownloadPath();
    if (downloadPath == null || widget.videoUrl == null) return;

    final fileName = widget.videoUrl!.split('/').last.split('?').first;
    final filePath = '$downloadPath/$fileName';

    if (await File(filePath).exists()) {
      if (mounted) {
        setState(() {
          _isDownloaded = true;
          _localVideoPath = filePath;
        });
      }
    }
  }

  Future<void> _downloadAndPlayVideo() async {
    if (_isDownloading) return;
    if (_isDownloaded) {
      await OpenFile.open(_localVideoPath);
      return;
    }

    if (mounted) setState(() => _isDownloading = true);

    try {
      final controller = Provider.of<ChatController>(context, listen: false);
      final downloadPath = await controller.getDownloadPath();
      if (downloadPath == null) return;

      final fileName = widget.videoUrl!.split('/').last.split('?').first;
      final filePath = '$downloadPath/$fileName';

      final response = await http.get(Uri.parse(widget.videoUrl!));
      await File(filePath).writeAsBytes(response.bodyBytes);

      if (mounted) {
        setState(() {
          _isDownloaded = true;
          _localVideoPath = filePath;
          _isDownloading = false;
        });
      }

      await OpenFile.open(filePath);
    } catch (_) {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final isSender = widget.senderId == currentUserId;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(widget.thumbnailUrl!, fit: BoxFit.cover),
                )
              : Container(
                  color: Colors.black,
                  child: const Icon(Icons.videocam_off, color: Colors.white),
                ),
        ),

        ValueListenableBuilder<Map<String, double>>(
          valueListenable: Provider.of<ChatController>(
            context,
          ).uploadProgressMap,
          builder: (context, progressMap, _) {
            final progress = progressMap[widget.uploadKey] ?? 0.0;
            if (progress > 0 && progress < 1) {
              return Container(
                color: Colors.black54,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        if (!isSender && !_isDownloaded && !_isDownloading)
          GestureDetector(
            onTap: _downloadAndPlayVideo,
            child: const Icon(
              Icons.download_for_offline,
              color: Colors.white,
              size: 30,
            ),
          ),
      ],
    );
  }
}

class _FileMessageContent extends StatefulWidget {
  final String? fileName;
  final int? fileSize;
  final String? fileUrl;
  final String? senderId;

  const _FileMessageContent({
    this.fileName,
    this.fileSize,
    this.fileUrl,
    required this.senderId,
  });

  @override
  State<_FileMessageContent> createState() => _FileMessageContentState();
}

class _FileMessageContentState extends State<_FileMessageContent> {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String _localFilePath = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfFileExists();
    });
  }

  Future<void> _checkIfFileExists() async {
    final controller = Provider.of<ChatController>(context, listen: false);
    final downloadPath = await controller.getDownloadPath();
    if (downloadPath == null) return;

    final filePath = '$downloadPath/${widget.fileName}';
    if (await File(filePath).exists()) {
      if (mounted) {
        setState(() {
          _isDownloaded = true;
          _localFilePath = filePath;
        });
      }
    }
  }

  String _formatBytes(int? bytes, int decimals) {
    if (bytes == null || bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<void> _downloadAndOpenFile() async {
    if (_isDownloading) return;

    final controller = Provider.of<ChatController>(context, listen: false);
    if (widget.fileUrl == null) return;

    if (_isDownloaded) {
      await OpenFile.open(_localFilePath);
      return;
    }

    if (mounted) setState(() => _isDownloading = true);

    try {
      final downloadPath = await controller.getDownloadPath();
      if (downloadPath == null) {
        if (mounted) setState(() => _isDownloading = false);
        return;
      }

      final filePath = '$downloadPath/${widget.fileName}';
      final response = await http.get(Uri.parse(widget.fileUrl!));
      await File(filePath).writeAsBytes(response.bodyBytes);

      if (mounted) {
        setState(() {
          _isDownloaded = true;
          _localFilePath = filePath;
          _isDownloading = false;
        });
      }

      await OpenFile.open(filePath);
    } catch (e) {
      if (mounted) setState(() => _isDownloading = false);
      errorPrint("Failed to download or open file: $e");
      customToastMsg("Failed to download or open file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = FirebaseAuth.instance;
    final currentUserId = firebaseAuth.currentUser!.uid;
    final isSender = widget.senderId == currentUserId;

    return GestureDetector(
      onTap: _downloadAndOpenFile,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.article, color: Colors.white, size: 40),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fileName ?? 'Document',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatBytes(widget.fileSize, 2),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (!isSender)
                  if (_isDownloading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else if (!_isDownloaded)
                    const Icon(Icons.download_for_offline, color: Colors.white)
                  else
                    const SizedBox(width: 24),
              ],
            ),
          ),

          ValueListenableBuilder<Map<String, double>>(
            valueListenable: Provider.of<ChatController>(
              context,
            ).uploadProgressMap,
            builder: (context, progressMap, _) {
              final progress = progressMap[widget.fileUrl] ?? 0.0;
              if (progress > 0 && progress < 1) {
                return Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
