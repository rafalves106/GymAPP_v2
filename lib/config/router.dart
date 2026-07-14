import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/work/work_shell.dart';
import '../presentation/screens/work/exercises_list_screen.dart';
import '../presentation/screens/work/exercise_detail_screen.dart';
import '../presentation/screens/work/exercise_form_screen.dart';
import '../presentation/screens/work/week_board_screen.dart';
import '../presentation/screens/work/training_detail_screen.dart';
import '../presentation/screens/work/training_form_screen.dart';
import '../presentation/screens/main/active_training_screen.dart';
import '../presentation/screens/main/training_summary_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({required String? token}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: token != null ? '/home/work/exercises' : '/login',
    redirect: (context, state) {
      final isLoggedIn = token != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home/work/exercises';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => WorkShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            redirect: (_, state) => '/home/work/exercises',
          ),
          GoRoute(
            path: '/home/work/exercises',
            builder: (context, state) => const ExercisesListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ExerciseFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ExerciseDetailScreen(
                  id: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => ExerciseFormScreen(
                      id: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/home/work/trainings',
            builder: (context, state) => const WeekBoardScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const TrainingFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => TrainingDetailScreen(
                  id: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => TrainingFormScreen(
                      id: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/active-training',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ActiveTrainingScreen(),
      ),
      GoRoute(
        path: '/training-summary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TrainingSummaryScreen(),
      ),
    ],
  );
}
