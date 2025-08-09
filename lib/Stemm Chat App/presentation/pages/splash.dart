import 'package:chatappstemm/Stemm%20Chat%20App/presentation/routes/appRoutes.dart';
import 'package:chatappstemm/Stemm%20Chat%20App/presentation/theme/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart'; // <-- Import the package
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../manager/auth_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // This part is correct. It fetches user details while the splash is showing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(
        context,
        listen: false,
      ).fetchCurrentUserDetails();
    });
    // This now calls our combined permission and navigation function.
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    await _requestPermissions();

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(LocalStorage.userId);
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (userId != null && currentUser != null && userId == currentUser.uid) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();
    if (statuses[Permission.storage]!.isPermanentlyDenied ||
        statuses[Permission.camera]!.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
