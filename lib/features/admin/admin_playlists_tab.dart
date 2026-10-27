import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/playlist_model.dart';
import '../../providers/playlist_providers.dart';
import '../../widgets/saffron_button.dart';

class AdminPlaylistsTab extends ConsumerWidget {
  const AdminPlaylistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(publishedPlaylistsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Curated & Festival Playlists',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage festival specials, morning suprabhatam, and temple collections.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SaffronButton(
                  label: 'Create Playlist',
                  icon: Icons.playlist_add_rounded,
                  onPressed: () => _showAddPlaylistDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: playlistsAsync.when(
                data: (playlists) {
                  return Card(
                    child: ListView.separated(
                      itemCount: playlists.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final pl = playlists[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.saffronContainer,
                            child: Text('📿'),
                          ),
                          title: Text(pl.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${pl.description ?? "Festival compilation"} • ${pl.songIds.length} tracks'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                                onPressed: () async {
                                  await ref.read(playlistRepositoryProvider).deletePlaylist(pl.id);
                                  ref.invalidate(publishedPlaylistsProvider);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffronPrimary)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlaylistDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Curated Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Playlist Title (e.g. Navratri Dandiya Chants)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description / Occasion'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              final newPlaylist = PlaylistModel(
                id: const Uuid().v4(),
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                published: true,
                createdAt: DateTime.now(),
              );
              await ref.read(playlistRepositoryProvider).savePlaylist(newPlaylist);
              ref.invalidate(publishedPlaylistsProvider);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
