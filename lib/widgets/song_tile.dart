import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/song_model.dart';
import '../providers/favorites_providers.dart';
import '../providers/player_providers.dart';
import 'devotional_image.dart';

class SongTile extends ConsumerWidget {
  final SongModel song;
  final List<SongModel>? playlistQueue;
  final VoidCallback? onTap;
  final bool showArtwork;
  final bool showCategoryChip;

  const SongTile({
    super.key,
    required this.song,
    this.playlistQueue,
    this.onTap,
    this.showArtwork = true,
    this.showCategoryChip = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(currentPlaybackStateProvider);
    final isCurrentSong = playbackState.currentSong?.id == song.id;
    final isPlaying = isCurrentSong && playbackState.isPlaying;

    final isFav = ref.watch(favoriteSongIdsProvider).contains(song.id);

    return InkWell(
      onTap: onTap ??
          () {
            ref.read(audioPlayerServiceProvider).playSong(
                  song,
                  queue: playlistQueue,
                );
            ref.read(recentlyPlayedIdsProvider.notifier).addRecent(song.id);
          },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Artwork / Playing Indicator
            if (showArtwork)
              Stack(
                alignment: Alignment.center,
                children: [
                  DevotionalImage(
                    imageUrl: song.artworkUrl,
                    width: 52,
                    height: 52,
                    borderRadius: BorderRadius.circular(10),
                    symbol: '🕉️',
                  ),
                  if (isCurrentSong)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPlaying ? Icons.equalizer_rounded : Icons.play_arrow_rounded,
                        color: AppColors.saffronLight,
                        size: 26,
                      ),
                    ),
                ],
              ),
            const SizedBox(width: 14),

            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isCurrentSong ? FontWeight.w700 : FontWeight.w600,
                      color: isCurrentSong ? AppColors.saffronDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (song.durationSeconds != null) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        Text(
                          Formatters.formatDuration(song.durationSeconds),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Favorite Button
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? AppColors.saffronPrimary : AppColors.textMuted,
                size: 22,
              ),
              onPressed: () {
                ref.read(favoriteSongIdsProvider.notifier).toggleFavorite(song.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackArtwork() {
    return Container(
      color: AppColors.saffronContainer.withOpacity(0.3),
      child: const Center(
        child: Text(
          '🕉️',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
