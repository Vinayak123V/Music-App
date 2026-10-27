import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti_music/data/repositories/song_repository.dart';

void main() {
  group('FirestoreSongRepository Fallback Catalog Tests', () {
    late FirestoreSongRepository repository;

    setUp(() {
      repository = FirestoreSongRepository();
    });

    test('getPublishedSongs returns populated list of devotional songs', () async {
      final songs = await repository.getPublishedSongs();
      expect(songs, isNotEmpty);
      expect(songs.every((s) => s.published), isTrue);
    });

    test('getPublishedSongs filters by categoryId correctly', () async {
      final mantras = await repository.getPublishedSongs(categoryId: 'mantras');
      expect(mantras, isNotEmpty);
      expect(mantras.every((s) => s.categoryId == 'mantras'), isTrue);
    });

    test('getPublishedSongs filters by deityId correctly', () async {
      final shivaSongs = await repository.getPublishedSongs(deityId: 'shiva');
      expect(shivaSongs, isNotEmpty);
      expect(shivaSongs.every((s) => s.deityId == 'shiva'), isTrue);
    });

    test('getFeaturedSongs returns songs marked as featured', () async {
      final featured = await repository.getFeaturedSongs();
      expect(featured, isNotEmpty);
      expect(featured.every((s) => s.featured), isTrue);
    });

    test('getSongOfTheDay returns a non-null song from catalog', () async {
      final sotd = await repository.getSongOfTheDay();
      expect(sotd, isNotNull);
      expect(sotd!.title, isNotEmpty);
    });

    test('searchSongs returns matching tracks by keyword', () async {
      final results = await repository.searchSongs(query: 'hanuman');
      expect(results, isNotEmpty);
      expect(results.first.title.toLowerCase(), contains('hanuman'));
    });
  });
}
