import 'package:demoparty_assistant/views/screens/contact_screen.dart';
import 'package:demoparty_assistant/views/screens/generic_content_screen.dart';
import 'package:demoparty_assistant/views/screens/news_screen.dart';
import 'package:demoparty_assistant/views/screens/settings_screen.dart';
import 'package:demoparty_assistant/views/screens/streams_screen.dart';
import 'package:demoparty_assistant/views/screens/users_screen.dart';
import 'package:demoparty_assistant/views/screens/voting_screen.dart';
import 'package:demoparty_assistant/views/screens/voting_results_screen.dart';
import 'package:demoparty_assistant/utils/navigation/auth_path_guard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:demoparty_assistant/views/screens/onboarding_screen.dart';
import 'package:demoparty_assistant/views/screens/time_table_screen.dart';
import 'package:demoparty_assistant/views/screens/authorization_screen.dart';
import 'app_router_paths.dart';

class AppRouter {
  static final authGuard = AuthGuard();
  static final router = GoRouter(
    initialLocation: AppRouterPaths.onboarding,
    routes: [
      GoRoute(
        name: 'timeTable',
        path: AppRouterPaths.timeTable,
        builder: (BuildContext context, GoRouterState state) {
          return TimeTableScreen();
        },
      ),
      GoRoute(
        name: 'onboarding',
        path: AppRouterPaths.onboarding,
        builder: (BuildContext context, GoRouterState state) {
          return Onboarding();
        },
      ),
      GoRoute(
        name: 'news',
        path: AppRouterPaths.news,
        builder: (BuildContext context, GoRouterState state) {
          return NewsScreen();
        },
      ),
      GoRoute(
        name: 'streams',
        path: AppRouterPaths.streams,
        builder: (BuildContext context, GoRouterState state) {
          return StreamsScreen();
        },
      ),
      GoRoute(
        name: 'authorization',
        path: AppRouterPaths.authorization,
        builder: (BuildContext context, GoRouterState state) {
          return Authorization();
        },
      ),
      GoRoute(
        name: 'contact',
        path: AppRouterPaths.contact,
        builder: (BuildContext context, GoRouterState state) {
          return const ContactScreen();
        },
      ),
      GoRoute(
        name: 'users',
        path: AppRouterPaths.users,
        builder: (BuildContext context, GoRouterState state) {
          return const UsersScreen();
        },
      ),
      GoRoute(
      path: '/voting_results',
      builder: (context, state) => VotingResultsScreen(),
      redirect: (context, state) async => await authGuard.redirect(state), // Guarded route.
    ),
    GoRoute(
      path: '/voting',
      builder: (context, state) => VotingScreen(),
      redirect: (context, state) async => await authGuard.redirect(state), // Guarded route.
    ),
      GoRoute(
        name: 'content',
        path: AppRouterPaths.generic_content,
        builder: (BuildContext context, GoRouterState state) {
          final url = state.uri.queryParameters['url']!;
          final title = state.uri.queryParameters['title']!;
          return GenericContentScreen(
            url: url,
            title: title,
            currentPage: title,
          );
        },
      ),
      GoRoute(
        name: 'settings',
        path: AppRouterPaths.settings,
        builder: (BuildContext context, GoRouterState state) {
          return SettingsScreen();
        },
      ),
    ],
  );
}
