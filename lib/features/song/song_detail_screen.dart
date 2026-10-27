import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/player_providers.dart';
import '../../providers/song_providers.dart';
import '../../widgets/devotional_image.dart';
import '../../widgets/saffron_button.dart';
import '../../widgets/song_tile.dart';

class SongDetailScreen extends ConsumerWidget {
  final String songId;

  const SongDetailScreen({super.key, required this.songId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(songByIdProvider(songId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Details'),
      ),
      body: songAsync.when(
        data: (song) {
          if (song == null) {
            return const Center(child: Text('Song metadata not found'));
          }

          final isFav = ref.watch(favoriteSongIdsProvider).contains(song.id);
          final relatedSongsAsync = ref.watch(
            publishedSongsProvider(SongFilter(deityId: song.deityId)),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Artwork
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: DevotionalImage(
                    imageUrl: song.artworkUrl,
                    width: 220,
                    height: 220,
                    borderRadius: BorderRadius.circular(20),
                    symbol: '🕉️',
                  ),
                ),
                const SizedBox(height: 20),

                // Title & Artist
                Text(
                  song.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  song.artist,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Metadata Badges Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildBadge('Language', song.language),
                    _buildBadge('Deity', song.deityId.toUpperCase()),
                    _buildBadge('Category', song.categoryId.toUpperCase()),
                    if (song.durationSeconds != null)
                      _buildBadge('Duration', Formatters.formatDuration(song.durationSeconds)),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons (Play & Favorite)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SaffronButton(
                      label: 'Listen Now',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {
                        ref.read(audioPlayerServiceProvider).playSong(song);
                        ref.read(recentlyPlayedIdsProvider.notifier).addRecent(song.id);
                      },
                    ),
                    const SizedBox(width: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.saffronPrimary),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.saffronPrimary : AppColors.textPrimary,
                      ),
                      label: Text(
                        isFav ? 'Favorited' : 'Favorite',
                        style: TextStyle(
                          color: isFav ? AppColors.saffronPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        ref.read(favoriteSongIdsProvider.notifier).toggleFavorite(song.id);
                      },
                    ),
                  ],
                ),

                if (song.description != null && song.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'About this Devotional Offering',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],

                // Rights Info (Verified Metadata)
                if (song.rights != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.creamCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, size: 16, color: AppColors.successGreen),
                            SizedBox(width: 6),
                            Text(
                              'Verified Streaming Rights',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Licensor: ${song.rights!.rightsHolder} • Ref: ${song.rights!.licenseReference}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],

                // Related Songs Section
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'More for ${song.deityId.toUpperCase()}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                relatedSongsAsync.when(
                  data: (related) {
                    final others = related.where((s) => s.id != song.id).toList();
                    if (others.isEmpty) {
                      return const Text('No other tracks found in this category.');
                    }
                    return Column(
                      children: others.take(4).map((s) => SongTile(song: s, playlistQueue: others)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffronPrimary)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffronPrimary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.saffronContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.saffronDark),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.saffronContainer.withOpacity(0.3),
      child: const Center(
        child: Text('🕉️', style: TextStyle(fontSize: 56)),
      ),
    );
  }
}
