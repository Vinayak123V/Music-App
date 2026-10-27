import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import 'song_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchCategoryFilterProvider = StateProvider<String?>((ref) => null);
final searchDeityFilterProvider = StateProvider<String?>((ref) => null);
final searchLanguageFilterProvider = StateProvider<String?>((ref) => null);

final searchResultsProvider = FutureProvider<List<SongModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final cat = ref.watch(searchCategoryFilterProvider);
  final deity = ref.watch(searchDeityFilterProvider);
  final lang = ref.watch(searchLanguageFilterProvider);

  final repo = ref.watch(songRepositoryProvider);
  return repo.searchSongs(
    query: query,
    categoryId: cat,
    deityId: deity,
    language: lang,
  );
});
