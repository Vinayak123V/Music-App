import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../data/models/playlist_model.dart';
import '../data/repositories/playlist_repository.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  FirebaseFirestore? firestore;
  if (AppConfig.isFirebaseInitialized) {
    try {
      firestore = FirebaseFirestore.instance;
    } catch (_) {}
  }
  return FirestorePlaylistRepository(firestore: firestore);
});

final publishedPlaylistsProvider = FutureProvider<List<PlaylistModel>>((ref) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getPublishedPlaylists();
});

final playlistByIdProvider = FutureProvider.family<PlaylistModel?, String>((ref, id) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getPlaylistById(id);
});
