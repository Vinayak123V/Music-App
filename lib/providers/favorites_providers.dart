import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/local_storage_service.dart';
import '../data/models/song_model.dart';
import 'song_providers.dart';

// Initialized at app startup in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at main()');
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

class FavoriteSongsNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;

  FavoriteSongsNotifier(this._storage) : super(_storage.getFavorites());

  Future<void> toggleFavorite(String songId) async {
    await _storage.toggleFavorite(songId);
    state = _storage.getFavorites();
  }

  bool isFavorite(String songId) => state.contains(songId);
}

final favoriteSongIdsProvider = StateNotifierProvider<FavoriteSongsNotifier, List<String>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return FavoriteSongsNotifier(storage);
});

final favoriteSongsListProvider = FutureProvider<List<SongModel>>((ref) async {
  final ids = ref.watch(favoriteSongIdsProvider);
  if (ids.isEmpty) return [];
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongsByIds(ids);
});

class RecentlyPlayedNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;

  RecentlyPlayedNotifier(this._storage) : super(_storage.getRecentlyPlayed());

  Future<void> addRecent(String songId) async {
    await _storage.addRecentlyPlayed(songId);
    state = _storage.getRecentlyPlayed();
  }
}

final recentlyPlayedIdsProvider = StateNotifierProvider<RecentlyPlayedNotifier, List<String>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return RecentlyPlayedNotifier(storage);
});

final recentlyPlayedSongsProvider = FutureProvider<List<SongModel>>((ref) async {
  final ids = ref.watch(recentlyPlayedIdsProvider);
  if (ids.isEmpty) return [];
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongsByIds(ids);
});
