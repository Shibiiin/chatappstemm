// presentation/screens/splash_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for a bit to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return; // Check if the widget is still in the tree

    final prefs = await SharedPreferences.getInstance();
    // Check if we have a saved user ID and if the Firebase user is still logged in
    final String? userId = prefs.getString('userId');
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (userId != null && currentUser != null && userId == currentUser.uid) {
      // User is logged in, go to dashboard
      context.go('/dashboard');
    } else {
      // User is not logged in, go to login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add your app logo here
            // For example: Image.asset('assets/logo.png', width: 150),
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
