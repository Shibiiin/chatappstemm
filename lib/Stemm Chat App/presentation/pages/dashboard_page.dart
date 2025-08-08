// presentation/screens/dashboard_page.dart
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Chats'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () {})],
      ),
      // body: ListTile(
      //   title: Text('Chat with User...'), // Placeholder
      //   subtitle: Text('lastMessage'),
      //   onTap: () {
      //     // Navigate to chat screen
      //   },
      // ),
    );
  }
}
