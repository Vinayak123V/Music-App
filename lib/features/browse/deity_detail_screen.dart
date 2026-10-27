import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/category_providers.dart';
import '../../providers/song_providers.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/song_tile.dart';

class DeityDetailScreen extends ConsumerWidget {
  final String deityId;

  const DeityDetailScreen({super.key, required this.deityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deitiesAsync = ref.watch(deitiesListProvider);
    final songsAsync = ref.watch(publishedSongsProvider(SongFilter(deityId: deityId)));

    final deity = deitiesAsync.value?.firstWhere(
      (d) => d.id == deityId,
      orElse: () => deitiesAsync.value!.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(deity?.name ?? 'Deity Songs'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            if (deity != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.saffronContainer.withOpacity(0.3),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.creamCard,
                      ),
                      child: const Center(child: Text('🔱', style: TextStyle(fontSize: 32))),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      deity.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deity.title,
                      style: const TextStyle(fontSize: 13, color: AppColors.saffronDark, fontWeight: FontWeight.w600),
                    ),
                    if (deity.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        deity.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ],
                ),
              ),

            // Songs List
            songsAsync.when(
              data: (songs) {
                if (songs.isEmpty) {
                  return const EmptyStateView(
                    title: 'No Songs Found',
                    message: 'No published tracks available for this deity yet.',
                  );
                }
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: songs.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 80,
                    color: AppColors.dividerLight,
                  ),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return SongTile(song: song, playlistQueue: songs);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.saffronPrimary),
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
