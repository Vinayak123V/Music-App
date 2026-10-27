import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/admin_login_screen.dart';
import '../../features/browse/categories_screen.dart';
import '../../features/browse/category_detail_screen.dart';
import '../../features/browse/deity_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/player/full_player_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/song/song_detail_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../providers/auth_providers.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorBrowse = GlobalKey<NavigatorState>(debugLabel: 'shellBrowse');
final _shellNavigatorSearch = GlobalKey<NavigatorState>(debugLabel: 'shellSearch');
final _shellNavigatorLibrary = GlobalKey<NavigatorState>(debugLabel: 'shellLibrary');
final _shellNavigatorSettings = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Admin Login
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),

      // Protected Admin Dashboard
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        redirect: (context, state) {
          final user = authRepo.currentUser;
          if (user == null || !user.isAdmin) {
            return '/admin/login';
          }
          return null;
        },
      ),

      // Full Player Screen
      GoRoute(
        path: '/player',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FullPlayerScreen(),
      ),

      // Song Details
      GoRoute(
        path: '/song/:songId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final songId = state.pathParameters['songId'] ?? '';
          return SongDetailScreen(songId: songId);
        },
      ),

      // Browse sub-routes
      GoRoute(
        path: '/browse/deity/:deityId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final deityId = state.pathParameters['deityId'] ?? '';
          return DeityDetailScreen(deityId: deityId);
        },
      ),
      GoRoute(
        path: '/browse/category/:categoryId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId'] ?? '';
          return CategoryDetailScreen(categoryId: categoryId);
        },
      ),

      // Main App Shell with Persistent Mini Player
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // 0. Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // 1. Browse
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBrowse,
            routes: [
              GoRoute(
                path: '/browse',
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),

          // 2. Search
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearch,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),

          // 3. Library
          StatefulShellBranch(
            navigatorKey: _shellNavigatorLibrary,
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),

          // 4. Settings
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettings,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
