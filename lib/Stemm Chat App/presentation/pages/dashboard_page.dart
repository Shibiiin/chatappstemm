import 'package:chatappstemm/Stemm%20Chat%20App/presentation/manager/auth_controller.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/theme/app_colors.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_print.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../manager/chat_Controller.dart';
import '../routes/appRoutes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.users);
        },
        child: const Icon(Icons.contacts),
      ),
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 30,
        backgroundColor: AppColors.kPrimaryColor,
        title: Consumer(
          builder: (context, value, child) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authController.userName ?? 'Recent Chat',
                style: TextStyle(color: AppColors.white),
              ),
              if (authController.phoneNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    authController.phoneNumber!, // Display phone
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: () {
              authController.logout(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatController.getChatListStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            errorPrint("Error: ${snapshot.error}");
            return Center(
              child: Text("Something went wrong: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                textAlign: TextAlign.center,
                "No active chats yet.\nTap the contacts button to start a conversation!",
              ),
            );
          }

          final chatDocs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                final chatData = chatDocs[index].data() as Map<String, dynamic>;
                final participantInfo =
                    chatData['participantInfo'] as Map<String, dynamic>;
                final otherUserId = participantInfo.keys.firstWhere(
                  (uid) => uid != currentUserId,
                  orElse: () => '',
                );
                final otherUserName =
                    participantInfo[otherUserId] ?? 'Unknown User';

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      otherUserName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      chatData['lastMessage'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      context.push(
                        AppRoutes.chat,
                        extra: {"name": otherUserName, "uid": otherUserId},
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
