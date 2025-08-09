import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_Toast.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_print.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatController with ChangeNotifier {
  List<QueryDocumentSnapshot> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  final firebaseAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;

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

  Future<void> sendMessage({
    required String receiverId,
    required String receiverName,
    required String message,
  }) async {
    alertPrint("Message Sending Started...");
    final String currentUserId = firebaseAuth.currentUser!.uid;
    final userDoc = await fireStore
        .collection('users')
        .doc(currentUserId)
        .get();
    final String currentUserName = userDoc.data()?['name'] ?? 'Unknown User';
    final Timestamp timestamp = Timestamp.now();

    ///Create the Chat Room ID
    List<String> participants = [currentUserId, receiverId];
    participants.sort();
    String chatRoomId = participants.join('_');
    alertPrint("Chat Room ID on send message: $chatRoomId");

    /// Define the document path
    final DocumentReference chatRoomDocRef = fireStore
        .collection('chats')
        .doc(chatRoomId);
    alertPrint("Chat Room Doc Ref: $chatRoomDocRef");

    /// Create document path
    final DocumentReference messageDocRef = chatRoomDocRef
        .collection('messages')
        .doc();
    alertPrint("Message Doc Ref: $messageDocRef");

    /// Get the unique ID for message
    final String messageId = messageDocRef.id;
    alertPrint("Message ID: $messageId");

    ///Create the Message Data
    Map<String, dynamic> newMessageData = {
      'messageId': messageId,
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'participants': participants,
    };
    alertPrint("New Message Data: $newMessageData");

    ///  Use a Batch Write to update everything at once
    final WriteBatch batch = fireStore.batch();
    alertPrint("Batch: $batch");

    /// Set the data for the new message document
    batch.set(messageDocRef, newMessageData);
    alertPrint("Message Doc Ref: $messageDocRef");

    ///Set/Update the metadata on the main chat room document (for the dashboard)
    batch.set(chatRoomDocRef, {
      'lastMessage': message,
      'lastMessageTimestamp': timestamp,
      'participants': participants,
      'participantInfo': {
        currentUserId: currentUserName,
        receiverId: receiverName,
      },
    }, SetOptions(merge: true));
    alertPrint("Chat Room Doc Ref: $chatRoomDocRef");

    await batch.commit();
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
}
