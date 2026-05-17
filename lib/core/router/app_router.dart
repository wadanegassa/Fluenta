import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/setup_screen.dart';
import '../../features/placement/presentation/placement_screen.dart';
import '../../features/placement/presentation/placement_result_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/lessons_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/community/presentation/chat_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/lesson/presentation/lesson_screen.dart';
import '../../features/lesson/presentation/assessment_screen.dart';
import '../../shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/signup' || state.uri.toString() == '/splash' || state.uri.toString() == '/onboarding';

      if (session == null) {
        if (loggingIn) return null;
        return '/login';
      }

      if (loggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(isLoginInitial: true),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const AuthScreen(isLoginInitial: false),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/placement',
        builder: (context, state) => const PlacementScreen(),
      ),
      GoRoute(
        path: '/placement/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          final level = extra?['level'] ?? 'A1';
          final feedback = extra?['feedback'] ?? '';
          return PlacementResultScreen(level: level, feedback: feedback);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/lessons',
            builder: (context, state) => const LessonsScreen(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LessonScreen(lessonId: id);
        },
      ),
      GoRoute(
        path: '/lesson/:id/assessment',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AssessmentScreen(lessonId: id);
        },
      ),
      GoRoute(
        path: '/community/room/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatScreen(roomId: id);
        },
      ),
    ],
  );
});
