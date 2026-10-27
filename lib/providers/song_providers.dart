import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../data/models/song_model.dart';
import '../data/repositories/song_repository.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) {
  FirebaseFirestore? firestore;
  if (AppConfig.isFirebaseInitialized) {
    try {
      firestore = FirebaseFirestore.instance;
    } catch (_) {}
  }
  return FirestoreSongRepository(firestore: firestore);
});

class SongFilter {
  final String? categoryId;
  final String? deityId;
  final String? language;

  const SongFilter({this.categoryId, this.deityId, this.language});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongFilter &&
          other.categoryId == categoryId &&
          other.deityId == deityId &&
          other.language == language;

  @override
  int get hashCode => Object.hash(categoryId, deityId, language);
}

final publishedSongsProvider = FutureProvider.family<List<SongModel>, SongFilter>((ref, filter) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getPublishedSongs(
    categoryId: filter.categoryId,
    deityId: filter.deityId,
    language: filter.language,
  );
});

final featuredSongsProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getFeaturedSongs();
});

final songOfTheDayProvider = FutureProvider<SongModel?>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongOfTheDay();
});

final songByIdProvider = FutureProvider.family<SongModel?, String>((ref, id) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getSongById(id);
});

final adminSongsListProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getAllSongsForAdmin();
});
