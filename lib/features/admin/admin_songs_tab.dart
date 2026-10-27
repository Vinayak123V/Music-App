import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/song_model.dart';
import '../../providers/player_providers.dart';
import '../../providers/song_providers.dart';
import '../../widgets/saffron_button.dart';
import 'admin_upload_song_dialog.dart';

class AdminSongsTab extends ConsumerStatefulWidget {
  const AdminSongsTab({super.key});

  @override
  ConsumerState<AdminSongsTab> createState() => _AdminSongsTabState();
}

class _AdminSongsTabState extends ConsumerState<AdminSongsTab> {
  String _searchFilter = '';
  String _selectedStatus = 'All'; // All, Published, Draft

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(adminSongsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Add Song Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Song & Content Catalog',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage audio files, verified licensing records, and publish statuses.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SaffronButton(
                  label: 'Add Devotional Song',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const AdminUploadSongDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search and Status Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search songs by title, artist, deity...',
                      prefixIcon: Icon(Icons.search_rounded),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchFilter = v.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'Published', child: Text('Published Only')),
                    DropdownMenuItem(value: 'Draft', child: Text('Drafts Only')),
                  ],
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Song List
            Expanded(
              child: songsAsync.when(
                data: (allSongs) {
                  final filtered = allSongs.where((s) {
                    if (_selectedStatus == 'Published' && !s.published) return false;
                    if (_selectedStatus == 'Draft' && s.published) return false;
                    if (_searchFilter.isNotEmpty) {
                      final matchTitle = s.title.toLowerCase().contains(_searchFilter);
                      final matchArtist = s.artist.toLowerCase().contains(_searchFilter);
                      final matchDeity = s.deityId.toLowerCase().contains(_searchFilter);
                      return matchTitle || matchArtist || matchDeity;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No songs match your filter criteria.'),
                    );
                  }

                  return Card(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final song = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.saffronContainer,
                            child: Text(song.published ? '🕉️' : '📝'),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  song.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (song.featured) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'FEATURED',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldDark),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text('${song.artist} • ${song.language} • ${song.deityId.toUpperCase()} • ${song.categoryId}'),
                              if (song.durationSeconds != null)
                                Text(
                                  'Duration: ${Formatters.formatDuration(song.durationSeconds)} • Licensor: ${song.rights?.rightsHolder ?? "Verified"}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Publish Toggle
                              Switch(
                                value: song.published,
                                activeColor: AppColors.successGreen,
                                onChanged: (value) async {
                                  await ref.read(songRepositoryProvider).togglePublishStatus(song.id, value);
                                  ref.invalidate(adminSongsListProvider);
                                  ref.invalidate(publishedSongsProvider);
                                },
                              ),

                              // Audio Preview Button
                              IconButton(
                                icon: const Icon(Icons.play_circle_outline, color: AppColors.saffronPrimary),
                                tooltip: 'Preview Audio',
                                onPressed: () {
                                  ref.read(audioPlayerServiceProvider).playSong(song);
                                },
                              ),

                              // Edit Button
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                                tooltip: 'Edit Song Metadata',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => AdminUploadSongDialog(songToEdit: song),
                                  );
                                },
                              ),

                              // Delete Button with confirmation
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                                tooltip: 'Delete Song',
                                onPressed: () => _confirmDelete(context, song),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.saffronPrimary),
                ),
                error: (err, _) => Center(child: Text('Error loading songs: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to permanently delete "${song.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(songRepositoryProvider).deleteSong(song.id);
              ref.invalidate(adminSongsListProvider);
              ref.invalidate(publishedSongsProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${song.title}" deleted.')),
                );
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
