import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/category_providers.dart';
import '../../providers/song_providers.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/song_tile.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final songsAsync = ref.watch(publishedSongsProvider(SongFilter(categoryId: categoryId)));

    final category = categoriesAsync.value?.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => categoriesAsync.value!.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.name ?? 'Category Songs'),
      ),
      body: songsAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const EmptyStateView(
              title: 'No Songs in this Category',
              message: 'Check back soon as new devotional audio is published regularly.',
            );
          }
          return ListView.separated(
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
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffronPrimary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
