import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/app_config.dart';
import '../models/playlist_model.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistModel>> getPublishedPlaylists();
  Future<PlaylistModel?> getPlaylistById(String id);
  Future<void> savePlaylist(PlaylistModel playlist);
  Future<void> deletePlaylist(String playlistId);
}

class FirestorePlaylistRepository implements PlaylistRepository {
  final FirebaseFirestore? _firestore;

  FirestorePlaylistRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>>? get _playlistsCollection =>
      _firestore?.collection('playlists');

  static final List<PlaylistModel> _defaultPlaylists = [
    PlaylistModel(
      id: 'shivaratri-special',
      title: 'Maha Shivaratri Special',
      description: 'Sacred stotrams, mantras, and meditative hymns honoring Mahadev.',
      songIds: ['shiva-tandav-stotram', 'maha-mrityunjaya-mantra'],
      language: 'Hindi / Sanskrit',
      published: true,
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Shiva_by_Raja_Ravi_Varma.jpg/600px-Shiva_by_Raja_Ravi_Varma.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
    PlaylistModel(
      id: 'morning-suprabhatam',
      title: 'Divine Morning Suprabhatam',
      description: 'Start your morning with spiritual peace, clarity, and holy chants.',
      songIds: ['gayatri-mantra-morning', 'hanuman-chalisa', 'jai-ganesh-deva-aarti'],
      language: 'Hindi',
      published: true,
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Saraswati_Raja_Ravi_Varma.jpg/600px-Saraswati_Raja_Ravi_Varma.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
    ),
    PlaylistModel(
      id: 'krishna-prem-ras',
      title: 'Krishna Prem Ras Bhajans',
      description: 'Immerse in the eternal nectar of Govinda, Radha-Krishna, and Vrindavan bliss.',
      songIds: ['achutam-keshavam', 'shree-ram-chandra-kripalu'],
      language: 'Hindi',
      published: true,
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Radha_Krishna_by_Raja_Ravi_Varma.jpg/600px-Radha_Krishna_by_Raja_Ravi_Varma.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  @override
  Future<List<PlaylistModel>> getPublishedPlaylists() async {
    if (AppConfig.isFirebaseInitialized && _playlistsCollection != null) {
      try {
        final snap = await _playlistsCollection!
            .where('published', isEqualTo: true)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => PlaylistModel.fromMap(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }
    return List.from(_defaultPlaylists);
  }

  @override
  Future<PlaylistModel?> getPlaylistById(String id) async {
    final list = await getPublishedPlaylists();
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlaylist(PlaylistModel playlist) async {
    if (AppConfig.isFirebaseInitialized && _playlistsCollection != null) {
      await _playlistsCollection!.doc(playlist.id).set(playlist.toMap(), SetOptions(merge: true));
    }
    final index = _defaultPlaylists.indexWhere((p) => p.id == playlist.id);
    if (index >= 0) {
      _defaultPlaylists[index] = playlist;
    } else {
      _defaultPlaylists.add(playlist);
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    if (AppConfig.isFirebaseInitialized && _playlistsCollection != null) {
      await _playlistsCollection!.doc(playlistId).delete();
    }
    _defaultPlaylists.removeWhere((p) => p.id == playlistId);
  }
}
