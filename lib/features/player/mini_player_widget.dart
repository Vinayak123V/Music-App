import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/player_providers.dart';
import '../../widgets/devotional_image.dart';
import 'full_player_screen.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentPlaybackStateProvider);
    final song = state.currentSong;

    if (song == null) {
      return const SizedBox.shrink();
    }

    final playerService = ref.read(audioPlayerServiceProvider);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FullPlayerScreen(),
              fullscreenDialog: true,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.miniPlayerBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Artwork
                    DevotionalImage(
                      imageUrl: song.artworkUrl,
                      width: 46,
                      height: 46,
                      borderRadius: BorderRadius.circular(10),
                      symbol: '🕉️',
                    ),
                    const SizedBox(width: 12),

                    // Title & Artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Previous Track Button
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: AppColors.textLight,
                        size: 24,
                      ),
                      onPressed: state.hasPrevious ? () => playerService.previous() : null,
                    ),

                    // Play/Pause Button with buffering indicator
                    state.isBuffering
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.saffronLight),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              state.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: AppColors.saffronLight,
                              size: 34,
                            ),
                            onPressed: () => playerService.playPause(),
                          ),

                    // Next Track Button
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textLight,
                        size: 24,
                      ),
                      onPressed: state.hasNext ? () => playerService.next() : null,
                    ),
                  ],
                ),
              ),

              // Linear Progress Bar at Bottom of Mini-Player
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffronLight),
                  minHeight: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return const Center(
      child: Text(
        '🕉️',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
