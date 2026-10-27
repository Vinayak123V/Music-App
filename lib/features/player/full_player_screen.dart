import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/player_providers.dart';
import '../../services/audio/playback_state.dart';
import '../../widgets/devotional_image.dart';
import 'queue_sheet.dart';

class FullPlayerScreen extends ConsumerStatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentPlaybackStateProvider);
    final song = state.currentSong;

    if (song == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text('No song currently loaded')),
      );
    }

    final playerService = ref.read(audioPlayerServiceProvider);
    final isFav = ref.watch(favoriteSongIdsProvider).contains(song.id);

    final positionMs = _dragValue != null
        ? _dragValue!
        : state.position.inMilliseconds.toDouble();
    final durationMs = state.duration.inMilliseconds > 0
        ? state.duration.inMilliseconds.toDouble()
        : (song.durationSeconds != null ? song.durationSeconds! * 1000.0 : 1.0);

    return Scaffold(
      backgroundColor: AppColors.fullPlayerGradientEnd,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.fullPlayerGradientStart,
              AppColors.fullPlayerGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final availableWidth = constraints.maxWidth;
              // Responsive artwork sizing to guarantee no overflow on any screen height
              final maxArtSize = min(
                availableWidth * 0.72,
                (availableHeight * 0.35).clamp(130.0, 260.0),
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'PLAYING DEVOTIONAL AUDIO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    song.language.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.goldAccent,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.queue_music_rounded, color: Colors.white, size: 24),
                                onPressed: () => _openQueueSheet(context),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Cover Artwork with responsive size
                        Center(
                          child: Container(
                            width: maxArtSize,
                            height: maxArtSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: DevotionalImage(
                              imageUrl: song.artworkUrl,
                              width: maxArtSize,
                              height: maxArtSize,
                              borderRadius: BorderRadius.circular(20),
                              symbol: '🕉️',
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Title, Artist and Favorite
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFav ? AppColors.saffronLight : Colors.white70,
                                  size: 26,
                                ),
                                onPressed: () {
                                  ref.read(favoriteSongIdsProvider.notifier).toggleFavorite(song.id);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Seek Bar & Timers
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3.5,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                  activeTrackColor: AppColors.saffronLight,
                                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                                  thumbColor: AppColors.saffronLight,
                                ),
                                child: Slider(
                                  min: 0.0,
                                  max: durationMs > 0 ? durationMs : 1.0,
                                  value: positionMs.clamp(0.0, durationMs > 0 ? durationMs : 1.0),
                                  onChanged: (value) {
                                    setState(() {
                                      _dragValue = value;
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    playerService.seek(Duration(milliseconds: value.toInt()));
                                    setState(() {
                                      _dragValue = null;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Formatters.formatDuration(
                                        Duration(milliseconds: positionMs.toInt()).inSeconds,
                                      ),
                                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                                    ),
                                    Text(
                                      Formatters.formatDuration(
                                        Duration(milliseconds: durationMs.toInt()).inSeconds,
                                      ),
                                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Playback Controls
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Shuffle Button
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle_rounded,
                                  color: state.isShuffleEnabled ? AppColors.saffronLight : Colors.white54,
                                  size: 22,
                                ),
                                onPressed: () => playerService.toggleShuffle(),
                              ),

                              // Previous Track Button
                              IconButton(
                                icon: const Icon(
                                  Icons.skip_previous_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                                onPressed: state.hasPrevious ? () => playerService.previous() : null,
                              ),

                              // Play/Pause Button
                              state.isBuffering
                                  ? Container(
                                      width: 60,
                                      height: 60,
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.saffronLight,
                                      ),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () => playerService.playPause(),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.saffronLight,
                                        ),
                                        child: Icon(
                                          state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          color: AppColors.textPrimary,
                                          size: 36,
                                        ),
                                      ),
                                    ),

                              // Next Track Button
                              IconButton(
                                icon: const Icon(
                                  Icons.skip_next_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                                onPressed: state.hasNext ? () => playerService.next() : null,
                              ),

                              // Repeat Button
                              IconButton(
                                icon: Icon(
                                  state.loopMode == AudioLoopMode.one
                                      ? Icons.repeat_one_rounded
                                      : Icons.repeat_rounded,
                                  color: state.loopMode != AudioLoopMode.off
                                      ? AppColors.saffronLight
                                      : Colors.white54,
                                  size: 22,
                                ),
                                onPressed: () => playerService.toggleLoopMode(),
                              ),
                            ],
                          ),
                        ),

                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                            ),
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openQueueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QueueSheet(),
    );
  }
}
