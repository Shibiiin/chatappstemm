import 'package:chatappstemm/Stemm%20Chat%20App/presentation/routes/appRoutes.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/widget/custom_print.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../manager/chat_Controller.dart';

class ContactBookPage extends StatefulWidget {
  @override
  State<ContactBookPage> createState() => _ContactBookPageState();
}

class _ContactBookPageState extends State<ContactBookPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatController>(context, listen: false).getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Example color
        title: const Text(
          'Registered Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<ChatController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              errorPrint('${controller.errorMessage}');
              return Center(child: Text(controller.errorMessage!));
            }
            if (controller.users.isEmpty) {
              return const Center(child: Text('No users found'));
            }
            return ListView.builder(
              itemCount: controller.users.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final user = controller.users[index];
                final userData = user.data() as Map<String, dynamic>;

                return Card(
                  elevation: 1,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(userData['name']?.toUpperCase() ?? 'NO NAME'),
                    subtitle: Text(userData['phoneNumber'] ?? 'NO PHONE'),
                    onTap: () async {
                      context.push(
                        AppRoutes.chat,
                        extra: {"name": userData['name'], "uid": user.id},
                      );
                      alertPrint('''
                      Navigating to chat screen
                      Name: ${userData['name']}
                      UID: ${user.id}
                      ''');
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
