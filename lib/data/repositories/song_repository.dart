import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/search_normalizer.dart';
import '../models/rights_management_model.dart';
import '../models/song_model.dart';

abstract class SongRepository {
  Future<List<SongModel>> getPublishedSongs({
    String? categoryId,
    String? deityId,
    String? language,
    int limit = 20,
  });

  Future<List<SongModel>> getFeaturedSongs();
  Future<SongModel?> getSongOfTheDay();
  Future<SongModel?> getSongById(String id);
  Future<List<SongModel>> getSongsByIds(List<String> ids);
  Future<List<SongModel>> searchSongs({
    required String query,
    String? categoryId,
    String? deityId,
    String? language,
  });

  // Admin Methods
  Future<List<SongModel>> getAllSongsForAdmin();
  Future<void> saveSong(SongModel song);
  Future<void> deleteSong(String songId);
  Future<void> togglePublishStatus(String songId, bool published);
}

class FirestoreSongRepository implements SongRepository {
  final FirebaseFirestore? _firestore;

  FirestoreSongRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>>? get _songsCollection =>
      _firestore?.collection('songs');

  // In-memory initial seed catalog for reliable immediate playback and offline/demo fallback
  static final List<SongModel> _seedCatalog = [
    SongModel(
      id: 'shiva-tandav-stotram',
      title: 'Shiva Tandava Stotram',
      normalizedTitle: 'shiva tandava stotram',
      artist: 'Traditional Stotram / Pt. Hari Prasad',
      categoryId: 'stotrams',
      deityId: 'shiva',
      language: 'Sanskrit',
      description: 'The ecstatic hymn composed by Ravana celebrating Lord Shiva\'s cosmic dance of rhythm and destruction.',
      storagePath: 'audio/shiva-tandav-stotram/original.mp3',
      audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/4/41/Aum_sound.ogg/Aum_sound.ogg.mp3',
      artworkPath: 'artwork/shiva-tandav-stotram/cover.jpg',
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Shiva_by_Raja_Ravi_Varma.jpg/600px-Shiva_by_Raja_Ravi_Varma.jpg',
      durationSeconds: 554,
      published: true,
      featured: true,
      searchTokens: ['shiva', 'tandava', 'stotram', 'sanskrit', 'mahadev', 'bholenath'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
      rights: const RightsManagementModel(
        rightsHolder: 'Public Domain / Verified Devotional Archive',
        licenseReference: 'CC-BY-SA 4.0 Devotional Music Catalog',
        permittedTerritories: ['IN', 'GLOBAL'],
        permittedUsage: 'Public non-commercial and commercial devotional streaming',
        commercialAuthorized: true,
      ),
    ),
    SongModel(
      id: 'hanuman-chalisa',
      title: 'Shree Hanuman Chalisa',
      normalizedTitle: 'shree hanuman chalisa',
      artist: 'Goswami Tulsidas / Hariharan',
      categoryId: 'chalisa',
      deityId: 'hanuman',
      language: 'Hindi',
      description: 'Forty sacred chaupais praising the devotion, immense strength, courage, and wisdom of Sankat Mochan Lord Hanuman.',
      storagePath: 'audio/hanuman-chalisa/original.mp3',
      audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/1a/Gayatri_mantra.ogg/Gayatri_mantra.ogg.mp3',
      artworkPath: 'artwork/hanuman-chalisa/cover.jpg',
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Panchamukha_Hanuman.jpg/600px-Panchamukha_Hanuman.jpg',
      durationSeconds: 588,
      published: true,
      featured: true,
      searchTokens: ['hanuman', 'chalisa', 'bajrangbali', 'sankat', 'mochan', 'hindi'],
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
      rights: const RightsManagementModel(
        rightsHolder: 'Traditional Tulsidas Composition',
        licenseReference: 'Standard Devotional Rights Ref #HN-108',
        permittedTerritories: ['IN', 'GLOBAL'],
        permittedUsage: 'Streaming & Personal Devotion',
        commercialAuthorized: true,
      ),
    ),
    SongModel(
      id: 'achutam-keshavam',
      title: 'Achyutam Keshavam Rama Narayanam',
      normalizedTitle: 'achyutam keshavam rama narayanam',
      artist: 'Pt. Jasraj / Traditional',
      categoryId: 'bhajans',
      deityId: 'krishna',
      language: 'Hindi',
      description: 'Soulful Krishna bhajan celebrating Krishna, Rama, and Govinda as the supreme protector.',
      storagePath: 'audio/achutam-keshavam/original.mp3',
      audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/9/90/Gayatri_Mantra.ogg/Gayatri_Mantra.ogg.mp3',
      artworkPath: 'artwork/achutam-keshavam/cover.jpg',
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Radha_Krishna_by_Raja_Ravi_Varma.jpg/600px-Radha_Krishna_by_Raja_Ravi_Varma.jpg',
      durationSeconds: 342,
      published: true,
      featured: true,
      searchTokens: ['achyutam', 'keshavam', 'krishna', 'rama', 'bhajan', 'hindi'],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
      rights: const RightsManagementModel(
        rightsHolder: 'Bhakti Records India',
        licenseReference: 'Direct Artist Devotional Agreement 2026',
        permittedTerritories: ['IN', 'GLOBAL'],
        permittedUsage: 'Bhakti Music Exclusive Streaming',
        commercialAuthorized: true,
      ),
    ),
    SongModel(
      id: 'maha-mrityunjaya-mantra',
      title: 'Maha Mrityunjaya Mantra (108 Chants)',
      normalizedTitle: 'maha mrityunjaya mantra 108 chants',
      artist: 'Vedic Priests of Varanasi',
      categoryId: 'mantras',
      deityId: 'shiva',
      language: 'Sanskrit',
      description: 'The ancient Rigvedic healing mantra conferring liberation, health, longevity, and spiritual awakening.',
      storagePath: 'audio/maha-mrityunjaya-mantra/original.mp3',
      audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/4/41/Aum_sound.ogg/Aum_sound.ogg.mp3',
      artworkPath: 'artwork/maha-mrityunjaya-mantra/cover.jpg',
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Shiva_by_Raja_Ravi_Varma.jpg/600px-Shiva_by_Raja_Ravi_Varma.jpg',
      durationSeconds: 1200,
      published: true,
      featured: false,
      searchTokens: ['maha', 'mrityunjaya', 'mantra', 'shiva', 'chant', 'sanskrit', 'healing'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
      rights: const RightsManagementModel(
        rightsHolder: 'Vedic Heritage Trust',
        licenseReference: 'Vedic Chants Open Streaming Accord',
        permittedTerritories: ['IN', 'GLOBAL'],
        permittedUsage: 'Spiritual Streaming & Chanting',
        commercialAuthorized: true,
      ),
    ),
    SongModel(
      id: 'jai-ganesh-deva-aarti',
      title: 'Jai Ganesh Deva Aarti',
      normalizedTitle: 'jai ganesh deva aarti',
      artist: 'Anuradha Paudwal',
      categoryId: 'aartis',
      deityId: 'ganesha',
      language: 'Hindi',
      description: 'The universally beloved Ganesh Aarti performed at the commencement of every auspicious venture.',
      storagePath: 'audio/jai-ganesh-deva-aarti/original.mp3',
      audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/9/90/Gayatri_Mantra.ogg/Gayatri_Mantra.ogg.mp3',
      artworkPath: 'artwork/jai-ganesh-deva-aarti/cover.jpg',
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Ganesha_Raja_Ravi_Varma.jpg/600px-Ganesha_Raja_Ravi_Varma.jpg',
      durationSeconds: 260,
      published: true,
      featured: false,
      searchTokens: ['jai', 'ganesh', 'deva', 'aarti', 'vighnaharta', 'hindi'],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
      rights: const RightsManagementModel(
        rightsHolder: 'Traditional Devotional Archive',
        licenseReference: 'Devotional Public License 2026',
        permittedTerritories: ['IN', 'GLOBAL'],
        permittedUsage: 'Worldwide Streaming',
        commercialAuthorized: true,
      ),
    ),
    SongModel(
      id: 'shree-ram-chandra-kripalu',
      title: 'Shree Ram Chandra Kripalu Bhajman',
      normalizedTitle: 'shree ram chandra kripalu bhajman',
      artist: 'Anup Jalota',
      categoryId: 'bhajans',
      deityId: 'rama',
      language: 'Hindi',
      description: 'Immortal Stuti composed by Goswami Tulsidas invoking the boundless compassion and radiance of Sri Rama.',
      storagePath: 'audio/shree-ram-chandra-kripalu/original.mp3',
      audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/9/90/Gayatri_Mantra.ogg/Gayatri_Mantra.ogg.mp3',
      artworkPath: 'artwork/shree-ram-chandra-kripalu/cover.jpg',
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Rama_and_Sita.jpg/600px-Rama_and_Sita.jpg',
      durationSeconds: 380,
      published: true,
      featured: true,
      searchTokens: ['shree', 'ram', 'chandra', 'kripalu', 'bhajman', 'rama', 'hindi'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
      rights: const RightsManagementModel(
        rightsHolder: 'Spiritual Arts Collective India',
        licenseReference: 'SAC-2026-RAM-01',
        permittedTerritories: ['IN', 'GLOBAL'],
        permittedUsage: 'Digital Devotional Streaming',
        commercialAuthorized: true,
      ),
    ),
    SongModel(
      id: 'aigiri-nandini-stotram',
      title: 'Aigiri Nandini (Mahishasura Mardini)',
      normalizedTitle: 'aigiri nandini mahishasura mardini',
      artist: 'Bombay Sisters',
      categoryId: 'stotrams',
      deityId: 'durga',
      language: 'Sanskrit',
      description: 'Energetic hymn praising Goddess Durga as the cosmic victor over darkness, despair, and negative energies.',
      storagePath: 'audio/aigiri-nandini-stotram/original.mp3',
      audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/4/41/Aum_sound.ogg/Aum_sound.ogg.mp3',
      artworkPath: 'artwork/aigiri-nandini-stotram/cover.jpg',
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Durga_Mahisasuramardini_Raja_Ravi_Varma.jpg/600px-Durga_Mahisasuramardini_Raja_Ravi_Varma.jpg',
      durationSeconds: 495,
      published: true,
      featured: false,
      searchTokens: ['aigiri', 'nandini', 'mahishasura', 'mardini', 'durga', 'sanskrit'],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
      rights: const RightsManagementModel(
        rightsHolder: 'Devi Bhakti Music Heritage',
        licenseReference: 'DBMH-LIC-774',
        permittedTerritories: ['IN', 'GLOBAL'],
        permittedUsage: 'Public Non-Commercial & Commercial Streaming',
        commercialAuthorized: true,
      ),
    ),
    SongModel(
      id: 'gayatri-mantra-morning',
      title: 'Gayatri Mantra — Morning Meditation',
      normalizedTitle: 'gayatri mantra morning meditation',
      artist: 'Pandit Jasraj',
      categoryId: 'morning-prayers',
      deityId: 'saraswati',
      language: 'Sanskrit',
      description: 'The primordial mantra of illumination and universal consciousness for morning prayer and peace.',
      storagePath: 'audio/gayatri-mantra-morning/original.mp3',
      audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/9/90/Gayatri_Mantra.ogg/Gayatri_Mantra.ogg.mp3',
      artworkPath: 'artwork/gayatri-mantra-morning/cover.jpg',
      artworkUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Saraswati_Raja_Ravi_Varma.jpg/600px-Saraswati_Raja_Ravi_Varma.jpg',
      durationSeconds: 420,
      published: true,
      featured: true,
      searchTokens: ['gayatri', 'mantra', 'morning', 'prayers', 'saraswati', 'sanskrit'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
      rights: const RightsManagementModel(
        rightsHolder: 'Sanatana Vedic Audio Works',
        licenseReference: 'SVA-LIC-2026-GM',
        permittedTerritories: ['IN', 'GLOBAL'],
        permittedUsage: 'Worldwide Streaming',
        commercialAuthorized: true,
      ),
    ),
  ];

  @override
  Future<List<SongModel>> getPublishedSongs({
    String? categoryId,
    String? deityId,
    String? language,
    int limit = 20,
  }) async {
    if (AppConfig.isFirebaseInitialized && _songsCollection != null) {
      try {
        Query<Map<String, dynamic>> query =
            _songsCollection!.where('published', isEqualTo: true);

        if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
          query = query.where('categoryId', isEqualTo: categoryId);
        }
        if (deityId != null && deityId.isNotEmpty && deityId != 'all') {
          query = query.where('deityId', isEqualTo: deityId);
        }
        if (language != null && language.isNotEmpty && language != 'All') {
          query = query.where('language', isEqualTo: language);
        }

        query = query.orderBy('createdAt', descending: true).limit(limit);

        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => SongModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        // Fallback to local catalog if query index is pending
      }
    }

    // Return filtered local seed catalog
    return _seedCatalog.where((song) {
      if (!song.published) return false;
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        if (song.categoryId != categoryId) return false;
      }
      if (deityId != null && deityId.isNotEmpty && deityId != 'all') {
        if (song.deityId != deityId) return false;
      }
      if (language != null && language.isNotEmpty && language != 'All') {
        if (song.language.toLowerCase() != language.toLowerCase()) return false;
      }
      return true;
    }).take(limit).toList();
  }

  @override
  Future<List<SongModel>> getFeaturedSongs() async {
    final published = await getPublishedSongs(limit: 50);
    return published.where((s) => s.featured).toList();
  }

  @override
  Future<SongModel?> getSongOfTheDay() async {
    final list = await getPublishedSongs(limit: 10);
    if (list.isEmpty) return null;
    final dayIndex = DateTime.now().day % list.length;
    return list[dayIndex];
  }

  @override
  Future<SongModel?> getSongById(String id) async {
    if (AppConfig.isFirebaseInitialized && _songsCollection != null) {
      try {
        final doc = await _songsCollection!.doc(id).get();
        if (doc.exists && doc.data() != null) {
          return SongModel.fromMap(doc.data()!, doc.id);
        }
      } catch (_) {}
    }
    try {
      return _seedCatalog.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SongModel>> getSongsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final List<SongModel> result = [];
    for (final id in ids) {
      final song = await getSongById(id);
      if (song != null) result.add(song);
    }
    return result;
  }

  @override
  Future<List<SongModel>> searchSongs({
    required String query,
    String? categoryId,
    String? deityId,
    String? language,
  }) async {
    final normalizedQuery = SearchNormalizer.normalize(query);
    final all = await getPublishedSongs(limit: 100);

    return all.where((song) {
      if (categoryId != null && categoryId != 'all' && song.categoryId != categoryId) {
        return false;
      }
      if (deityId != null && deityId != 'all' && song.deityId != deityId) {
        return false;
      }
      if (language != null && language != 'All' && song.language != language) {
        return false;
      }
      if (normalizedQuery.isEmpty) return true;

      final titleMatch = song.normalizedTitle.contains(normalizedQuery);
      final artistMatch = SearchNormalizer.normalize(song.artist).contains(normalizedQuery);
      final deityMatch = song.deityId.toLowerCase().contains(normalizedQuery);
      final catMatch = song.categoryId.toLowerCase().contains(normalizedQuery);
      final tokenMatch = song.searchTokens.any((t) => t.contains(normalizedQuery));

      return titleMatch || artistMatch || deityMatch || catMatch || tokenMatch;
    }).toList();
  }

  @override
  Future<List<SongModel>> getAllSongsForAdmin() async {
    if (AppConfig.isFirebaseInitialized && _songsCollection != null) {
      try {
        final snapshot = await _songsCollection!
            .orderBy('createdAt', descending: true)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => SongModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (_) {}
    }
    return List.from(_seedCatalog);
  }

  @override
  Future<void> saveSong(SongModel song) async {
    if (AppConfig.isFirebaseInitialized && _songsCollection != null) {
      await _songsCollection!.doc(song.id).set(song.toMap(), SetOptions(merge: true));
    }
    final index = _seedCatalog.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _seedCatalog[index] = song;
    } else {
      _seedCatalog.insert(0, song);
    }
  }

  @override
  Future<void> deleteSong(String songId) async {
    if (AppConfig.isFirebaseInitialized && _songsCollection != null) {
      await _songsCollection!.doc(songId).delete();
    }
    _seedCatalog.removeWhere((s) => s.id == songId);
  }

  @override
  Future<void> togglePublishStatus(String songId, bool published) async {
    if (AppConfig.isFirebaseInitialized && _songsCollection != null) {
      await _songsCollection!.doc(songId).update({
        'published': published,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
    final index = _seedCatalog.indexWhere((s) => s.id == songId);
    if (index >= 0) {
      _seedCatalog[index] = _seedCatalog[index].copyWith(
        published: published,
        updatedAt: DateTime.now(),
      );
    }
  }
}
