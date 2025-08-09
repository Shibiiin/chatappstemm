import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../manager/auth_controller.dart';
import '../theme/app_colors.dart';
import 'dashboard_page.dart';

class ChatsScreenBottomBar extends StatefulWidget {
  const ChatsScreenBottomBar({super.key});

  @override
  State<ChatsScreenBottomBar> createState() => _ChatsScreenBottomBarState();
}

class _ChatsScreenBottomBarState extends State<ChatsScreenBottomBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    List<Widget> widgetOptions = <Widget>[
      const DashboardPage(),
      const Center(child: Text("Status Screen")),
      const Center(child: Text("Calls Screen")),
      const Center(child: Text("Profile Screen")),
    ];

    return Scaffold(
      body: widgetOptions[_selectedIndex],
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.messenger), label: "Chats"),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.logo_whatsapp),
          label: "Status",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.kPrimaryColor,
      automaticallyImplyLeading: false,
      title: const Text("Chats"),
      actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
    );
  }
}
