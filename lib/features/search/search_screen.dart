import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/search_providers.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/song_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final selectedLanguage = ref.watch(searchLanguageFilterProvider);
    final selectedCategory = ref.watch(searchCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Devotional Audio'),
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search title, singer, mantra, deity...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.saffronPrimary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // Filter Chips Row
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Language Filters
                ...AppConstants.supportedLanguages.map((lang) {
                  final isSelected = selectedLanguage == (lang == 'All' ? null : lang);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(lang),
                      selected: isSelected,
                      selectedColor: AppColors.saffronContainer,
                      checkmarkColor: AppColors.saffronDark,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? AppColors.saffronDark : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        ref.read(searchLanguageFilterProvider.notifier).state =
                            selected ? (lang == 'All' ? null : lang) : null;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.dividerLight),

          // Search Results
          Expanded(
            child: searchResultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return const EmptyStateView(
                    symbol: '🔍',
                    title: 'No Matching Audio Found',
                    message: 'Try checking your spelling or adjusting your language and category filters.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 80,
                    color: AppColors.dividerLight,
                  ),
                  itemBuilder: (context, index) {
                    final song = results[index];
                    return SongTile(song: song, playlistQueue: results);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.saffronPrimary),
              ),
              error: (err, _) => Center(
                child: Text('Search error: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
