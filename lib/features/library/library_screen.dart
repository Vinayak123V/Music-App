import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/playlist_providers.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/song_tile.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoriteSongsListProvider);
    final playlistsAsync = ref.watch(publishedPlaylistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Devotional Library'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.saffronDark,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.saffronPrimary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Favorites ❤️'),
            Tab(text: 'Curated Playlists'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Favorites Tab
          favoritesAsync.when(
            data: (favs) {
              if (favs.isEmpty) {
                return const EmptyStateView(
                  symbol: '🤍',
                  title: 'No Favorites Saved',
                  message: 'Tap the heart icon on any bhajan, aarti, or mantra to add it to your daily devotional favorites.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: favs.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 80,
                  color: AppColors.dividerLight,
                ),
                itemBuilder: (context, index) {
                  final song = favs[index];
                  return SongTile(song: song, playlistQueue: favs);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffronPrimary)),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),

          // 2. Playlists Tab
          playlistsAsync.when(
            data: (playlists) {
              if (playlists.isEmpty) {
                return const EmptyStateView(
                  symbol: '📿',
                  title: 'No Playlists Found',
                  message: 'Curated devotional playlists will appear here.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: playlists.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.saffronContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('📿', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      title: Text(
                        playlist.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        playlist.description ?? '${playlist.songIds.length} tracks • ${playlist.language}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.play_circle_fill_rounded, color: AppColors.saffronPrimary, size: 36),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffronPrimary)),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }
}
