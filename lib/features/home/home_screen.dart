import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/song_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/song_providers.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/section_header.dart';
import '../../widgets/song_tile.dart';
import 'widgets/deity_chips_row.dart';
import 'widgets/hero_featured_card.dart';
import 'widgets/prayers_carousel.dart';
import 'widgets/song_of_the_day_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedDeityId;

  String _getDevotionalGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return '🌅 Shubh Prabhat'; // Good morning
    } else if (hour >= 12 && hour < 17) {
      return '☀️ Shubh Dopahar'; // Good afternoon
    } else if (hour >= 17 && hour < 21) {
      return '🪔 Shubh Sandhya'; // Good evening
    } else {
      return '🕉️ Namaste & Har Har Mahadev';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = ref.watch(preferredLanguageProvider);
    final filter = SongFilter(
      deityId: _selectedDeityId,
      language: selectedLanguage == 'All' ? null : selectedLanguage,
    );

    final publishedSongsAsync = ref.watch(publishedSongsProvider(filter));
    final featuredSongsAsync = ref.watch(featuredSongsProvider);
    final songOfTheDayAsync = ref.watch(songOfTheDayProvider);
    final recentlyPlayedAsync = ref.watch(recentlyPlayedSongsProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getDevotionalGreeting(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.saffronDark,
              ),
            ),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Language selector button
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate_rounded, color: AppColors.saffronPrimary),
            tooltip: 'Choose Language',
            initialValue: selectedLanguage,
            onSelected: (lang) {
              ref.read(preferredLanguageProvider.notifier).setLanguage(lang);
            },
            itemBuilder: (context) {
              return AppConstants.supportedLanguages.map((lang) {
                return PopupMenuItem(
                  value: lang,
                  child: Text(
                    lang,
                    style: TextStyle(
                      fontWeight: lang == selectedLanguage ? FontWeight.bold : FontWeight.normal,
                      color: lang == selectedLanguage ? AppColors.saffronPrimary : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList();
            },
          ),

          // Admin Dashboard button
          IconButton(
            icon: Icon(
              isAdmin ? Icons.admin_panel_settings_rounded : Icons.login_rounded,
              color: AppColors.saffronPrimary,
            ),
            tooltip: isAdmin ? 'Admin Console' : 'Admin Login',
            onPressed: () {
              if (isAdmin) {
                context.push('/admin/dashboard');
              } else {
                context.push('/admin/login');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.saffronPrimary,
        onRefresh: () async {
          ref.invalidate(publishedSongsProvider);
          ref.invalidate(featuredSongsProvider);
          ref.invalidate(songOfTheDayProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Jump
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: InkWell(
                  onTap: () => context.go('/search'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColors.textMuted),
                        SizedBox(width: 12),
                        Text(
                          'Search bhajans, aartis, mantras, deities...',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Deity Quick Filter Row
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: DeityChipsRow(
                  selectedDeityId: _selectedDeityId,
                  onSelectDeity: (deityId) {
                    setState(() {
                      _selectedDeityId = deityId;
                    });
                  },
                ),
              ),

              // Featured Hero Card
              featuredSongsAsync.when(
                data: (featuredList) {
                  if (featuredList.isEmpty) return const SizedBox.shrink();
                  return HeroFeaturedCard(song: featuredList.first);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Song of the Day Card
              songOfTheDayAsync.when(
                data: (song) {
                  if (song == null) return const SizedBox.shrink();
                  return SongOfTheDayCard(song: song);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Recently Played (if any)
              recentlyPlayedAsync.when(
                data: (recents) {
                  if (recents.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const SectionHeader(title: 'Recently Played'),
                      ...recents.take(3).map((s) => SongTile(song: s, playlistQueue: recents)),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Main Catalog by Categories & Sections
              publishedSongsAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return const EmptyStateView(
                      title: 'No Devotional Songs Found',
                      message: 'No published tracks match your selected deity or language filter. Please try a different selection or clear filters.',
                    );
                  }

                  // Segregate by categories
                  final bhajans = songs.where((s) => s.categoryId == 'bhajans').toList();
                  final aartis = songs.where((s) => s.categoryId == 'aartis').toList();
                  final mantras = songs.where((s) => s.categoryId == 'mantras').toList();
                  final morning = songs.where((s) => s.categoryId == 'morning-prayers').toList();
                  final stotrams = songs.where((s) => s.categoryId == 'stotrams' || s.categoryId == 'chalisa').toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Popular Bhajans
                      if (bhajans.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SectionHeader(
                          title: 'Popular Bhajans',
                          actionLabel: 'See All',
                          onActionTap: () => context.push('/browse/category/bhajans'),
                        ),
                        ...bhajans.take(4).map((s) => SongTile(song: s, playlistQueue: songs)),
                      ],

                      // Morning Prayers Carousel
                      if (morning.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        PrayersCarousel(
                          title: 'Morning Prayers & Suprabhatam',
                          icon: '🌅',
                          songs: morning,
                        ),
                      ],

                      // Sacred Mantras & Chants
                      if (mantras.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SectionHeader(
                          title: 'Mantras & Healing Chants',
                          actionLabel: 'See All',
                          onActionTap: () => context.push('/browse/category/mantras'),
                        ),
                        ...mantras.take(3).map((s) => SongTile(song: s, playlistQueue: songs)),
                      ],

                      // Aartis
                      if (aartis.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SectionHeader(
                          title: 'Devotional Aartis',
                          actionLabel: 'See All',
                          onActionTap: () => context.push('/browse/category/aartis'),
                        ),
                        ...aartis.take(3).map((s) => SongTile(song: s, playlistQueue: songs)),
                      ],

                      // Chalisa & Stotrams
                      if (stotrams.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SectionHeader(
                          title: 'Chalisa & Sacred Stotrams',
                          actionLabel: 'See All',
                          onActionTap: () => context.push('/browse/category/stotrams'),
                        ),
                        ...stotrams.take(4).map((s) => SongTile(song: s, playlistQueue: songs)),
                      ],
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.saffronPrimary),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
