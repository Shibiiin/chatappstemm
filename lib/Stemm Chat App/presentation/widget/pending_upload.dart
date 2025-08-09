import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../manager/chat_Controller.dart';

class PendingUploadWidget extends StatefulWidget {
  final File file;
  final bool isVideo;

  const PendingUploadWidget({
    super.key,
    required this.file,
    required this.isVideo,
  });

  @override
  State<PendingUploadWidget> createState() => _PendingUploadWidgetState();
}

class _PendingUploadWidgetState extends State<PendingUploadWidget> {
  Uint8List? _thumbnailData;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    if (!widget.isVideo) return;
    final uint8list = await VideoThumbnail.thumbnailData(
      video: widget.file.path,
      imageFormat: ImageFormat.WEBP,
      maxWidth: 200,
      quality: 25,
    );
    if (mounted) {
      setState(() {
        _thumbnailData = uint8list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.isVideo
                      ? (_thumbnailData != null
                            ? Image.memory(
                                _thumbnailData!,
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 200,
                                width: 200,
                                color: Colors.black,
                              ))
                      : Image.file(
                          widget.file,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                ),

                ValueListenableBuilder<double>(
                  valueListenable: Provider.of<ChatController>(
                    context,
                    listen: false,
                  ).uploadProgress,
                  builder: (context, progress, _) {
                    return Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
