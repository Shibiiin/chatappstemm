import 'dart:io';

import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_Toast.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_print.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatController with ChangeNotifier {
  List<QueryDocumentSnapshot> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  final firebaseAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<QueryDocumentSnapshot> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String currentUserId = firebaseAuth.currentUser!.uid;
      final snapshot = await fireStore.collection('users').get();

      _users = snapshot.docs.where((doc) => doc.id != currentUserId).toList();
    } catch (e) {
      customToastMsg("Failed to fetch the users $e");
      _errorMessage = 'Something went wrong: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///send normal message
  Future<void> sendMessage({
    required String receiverId,
    required String receiverName,
    required Map<String, dynamic> messageData,
  }) async {
    final String currentUserId = firebaseAuth.currentUser!.uid;
    final userDoc = await fireStore
        .collection('users')
        .doc(currentUserId)
        .get();
    final String currentUserName = userDoc.data()?['name'] ?? 'Unknown User';
    final Timestamp timestamp = Timestamp.now();

    List<String> participants = [currentUserId, receiverId];
    participants.sort();
    String chatRoomId = participants.join('_');

    final DocumentReference chatRoomDocRef = fireStore
        .collection('chats')
        .doc(chatRoomId);
    final DocumentReference messageDocRef = chatRoomDocRef
        .collection('messages')
        .doc();

    // Add common fields to the message data
    messageData.addAll({
      'messageId': messageDocRef.id,
      'senderId': currentUserId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'participants': participants,
    });

    // Determine lastMessage text for the dashboard
    String lastMessageText;
    switch (messageData['type']) {
      case 'video':
        lastMessageText = 'sent a video';
        break;
      case 'file':
        lastMessageText = messageData['fileName'] ?? 'sent a file';
        break;
      default:
        lastMessageText = messageData['message'] ?? '';
    }

    final WriteBatch batch = fireStore.batch();
    batch.set(messageDocRef, messageData);
    batch.set(chatRoomDocRef, {
      'lastMessage': lastMessageText,
      'lastMessageTimestamp': timestamp,
      'participants': participants,
      'participantInfo': {
        currentUserId: currentUserName,
        receiverId: receiverName,
      },
    }, SetOptions(merge: true));

    await batch.commit();
  }

  ///send media message
  Future<void> sendMediaMessage({
    required File file,
    required String receiverId,
    required String receiverName,
    required String type,
  }) async {
    try {
      alertPrint("SendMedia starting...");
      final String currentUserId = firebaseAuth.currentUser!.uid;
      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join('_');
      String fileName = file.path.split('/').last;

      String fileUrl = await uploadFile(file, 'chats/$chatRoomId/$fileName');

      Map<String, dynamic> messageData;

      if (type == 'video') {
        ///For video, generate and upload a thumbnail
        File? thumbnail = await generateVideoThumbnail(file.path);
        String thumbnailUrl = '';
        if (thumbnail != null) {
          thumbnailUrl = await uploadFile(
            thumbnail,
            'chats/$chatRoomId/thumbnails/$fileName.webp',
          );
        }
        messageData = {
          'type': 'video',
          'url': fileUrl,
          'thumbnailUrl': thumbnailUrl,
        };
        successPrint("Message Data Type: video $messageData}");
      } else {
        // 'file'
        messageData = {
          'type': 'file',
          'url': fileUrl,
          'fileName': fileName,
          'fileSize': await file.length(),
        };

        successPrint("Message Data Type: video $messageData}");
      }

      await sendMessage(
        receiverId: receiverId,
        receiverName: receiverName,
        messageData: messageData,
      );
    } catch (e) {
      errorPrint("Failed to Send the Media $e");
      customToastMsg("Failed to send media: $e");
    }
  }

  ///get messages
  Stream<QuerySnapshot> getMessages(String receiverId) {
    alertPrint("Message fetching started");
    List<String> ids = [firebaseAuth.currentUser!.uid, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    alertPrint("Chat Room ID: $chatRoomId");

    successPrint("Message fetched from firestore");
    return fireStore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  ///get the list to Dashboard
  Stream<QuerySnapshot> getChatListStream() {
    alertPrint("Chat List fetching");
    return fireStore
        .collection('chats')
        .where('participants', arrayContains: firebaseAuth.currentUser!.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  ///Upload files
  ValueNotifier<double> uploadProgress = ValueNotifier(0.0);

  Future<String> uploadFile(File file, String path) async {
    uploadProgress.value = 0.0;
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      uploadProgress.value = progress;
    });

    final snapshot = await uploadTask.whenComplete(() {});
    uploadProgress.value = 0.0;
    return await snapshot.ref.getDownloadURL();
  }

  ///generate video thumbnail
  Future<File?> generateVideoThumbnail(String videoPath) async {
    alertPrint("Generating Video Thumbnail");
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      quality: 25,
    );
    alertPrint("Video Thumbnail Generated");
    return fileName != null ? File(fileName) : null;
  }

  ///download the files

  Future<String?> getDownloadPath() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 33) {
          final status = await [
            Permission.photos,
            Permission.videos,
            Permission.audio,
          ].request();

          if (status.values.any((p) => p.isDenied)) {
            errorPrint("Permission denied.");
            return null;
          }
        } else if (sdkInt >= 30) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) return null;
        } else {
          final status = await Permission.storage.request();
          if (!status.isGranted) return null;
        }

        final downloadsDir = Directory(
          '/storage/emulated/0/Download/ChatAppStemm',
        );
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return downloadsDir.path;
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      }
    } catch (err) {
      errorPrint("Error getting download path: $err");
    }
    return null;
  }
}
