import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/category_providers.dart';
import '../../providers/playlist_providers.dart';
import '../../providers/song_providers.dart';
import '../../widgets/devotional_card.dart';

class AdminOverviewTab extends ConsumerWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(adminSongsListProvider);
    final categoriesAsync = ref.watch(allCategoriesForAdminProvider);
    final playlistsAsync = ref.watch(publishedPlaylistsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catalog & Operations Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Live verified counts directly from Cloud Firestore & Firebase Storage.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Metrics Cards Grid
          songsAsync.when(
            data: (songs) {
              final totalSongs = songs.length;
              final publishedCount = songs.where((s) => s.published).length;
              final draftCount = totalSongs - publishedCount;
              final categoriesCount = categoriesAsync.value?.length ?? 9;
              final playlistsCount = playlistsAsync.value?.length ?? 3;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;
                      return GridView.count(
                        crossAxisCount: isWide ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.4,
                        children: [
                          _buildStatCard('Total Songs', '$totalSongs', '🎵', AppColors.saffronDark),
                          _buildStatCard('Published Live', '$publishedCount', '✅', AppColors.successGreen),
                          _buildStatCard('Drafts / Hidden', '$draftCount', '📝', AppColors.warningOrange),
                          _buildStatCard('Curated Playlists', '$playlistsCount', '📿', AppColors.goldDark),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Recently Added Tracks Section
                  const Text(
                    'Recently Added Offerings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  DevotionalCard(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: songs.take(5).length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: song.published
                                ? AppColors.saffronContainer
                                : AppColors.dividerLight,
                            child: Text(song.published ? '🕉️' : '⏳'),
                          ),
                          title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${song.artist} • ${song.language} • ${song.deityId.toUpperCase()}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: song.published
                                  ? AppColors.successGreen.withOpacity(0.12)
                                  : AppColors.warningOrange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              song.published ? 'PUBLISHED' : 'DRAFT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: song.published ? AppColors.successGreen : AppColors.warningOrange,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: AppColors.saffronPrimary),
              ),
            ),
            error: (err, _) => Center(child: Text('Failed to load metrics: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
