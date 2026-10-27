import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_providers.dart';
import 'admin_categories_tab.dart';
import 'admin_overview_tab.dart';
import 'admin_playlists_tab.dart';
import 'admin_songs_tab.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    AdminOverviewTab(),
    AdminSongsTab(),
    AdminCategoriesTab(),
    AdminPlaylistsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.saffronContainer,
              ),
              child: const Text('🪔', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            const Text(
              'Bhakti Music • Admin Console',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Return to App
          TextButton.icon(
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to App'),
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(width: 8),

          // Sign out
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.errorRed),
            tooltip: 'Sign Out Admin',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/admin/login');
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          // Navigation Rail on Web / Wide Desktop
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.creamCard,
              selectedIconTheme: const IconThemeData(color: AppColors.saffronPrimary),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.saffronDark,
                fontWeight: FontWeight.bold,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music_rounded),
                  label: Text('Songs & Audio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.category_outlined),
                  selectedIcon: Icon(Icons.category_rounded),
                  label: Text('Categories'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.playlist_play_rounded),
                  selectedIcon: Icon(Icons.playlist_play_rounded),
                  label: Text('Playlists'),
                ),
              ],
            ),

          if (isWide) const VerticalDivider(width: 1, color: AppColors.dividerLight),

          // Tab Content
          Expanded(child: _tabs[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: !isWide
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (idx) => setState(() => _selectedIndex = idx),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
                BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: 'Songs'),
                BottomNavigationBarItem(icon: Icon(Icons.category_rounded), label: 'Categories'),
                BottomNavigationBarItem(icon: Icon(Icons.playlist_play_rounded), label: 'Playlists'),
              ],
            )
          : null,
    );
  }
}
