import 'package:chatappstemm/Stemm%20Chat%20App/presentation/pages/message_page.dart';
import 'package:go_router/go_router.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/contact_book_page.dart';
import '../pages/dashboard_bottomBar_screen.dart';
import '../pages/splash.dart';
import '../widget/video_player.dart';
import 'appRoutes.dart';

class GoRouterPage {
  final GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(path: AppRoutes.login, builder: (context, state) => LoginPage()),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const ChatsScreenBottomBar(),
      ),
      GoRoute(
        path: AppRoutes.users,
        builder: (context, state) => ContactBookPage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;

          final String userId = data['uid'] as String;
          final String userName = data['name'] as String;

          return MessagesScreen(id: userId, name: userName);
        },
      ),
      GoRoute(
        path: AppRoutes.videoPlayer,
        builder: (context, state) {
          final String videoUrl = state.extra as String;
          return VideoPlayerPage(videoUrl: videoUrl);
        },
      ),
    ],
  );
}
