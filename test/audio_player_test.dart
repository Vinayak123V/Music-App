import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti_music/services/audio/playback_state.dart';
import 'package:bhakti_music/data/models/song_model.dart';

void main() {
  group('DevotionalPlaybackState Tests', () {
    final testSong = SongModel(
      id: 'test-song-1',
      title: 'Achyutam Keshavam',
      normalizedTitle: 'achyutam keshavam',
      artist: 'Pt. Jasraj',
      categoryId: 'bhajans',
      deityId: 'krishna',
      language: 'Hindi',
      storagePath: 'audio/test-song-1/original.mp3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'admin',
    );

    test('Initial state is empty with zero duration and no song', () {
      const state = DevotionalPlaybackState();
      expect(state.hasSong, isFalse);
      expect(state.isPlaying, isFalse);
      expect(state.progress, 0.0);
    });

    test('progress calculates fractional position properly', () {
      final state = DevotionalPlaybackState(
        currentSong: testSong,
        duration: const Duration(seconds: 200),
        position: const Duration(seconds: 100),
      );
      expect(state.progress, 0.5);
    });

    test('Queue navigation indicators hasPrevious and hasNext evaluate correctly', () {
      final stateMiddle = DevotionalPlaybackState(
        currentSong: testSong,
        queue: [testSong, testSong, testSong],
        currentIndex: 1,
      );
      expect(stateMiddle.hasPrevious, isTrue);
      expect(stateMiddle.hasNext, isTrue);

      final stateFirst = DevotionalPlaybackState(
        currentSong: testSong,
        queue: [testSong, testSong],
        currentIndex: 0,
      );
      expect(stateFirst.hasPrevious, isFalse);
      expect(stateFirst.hasNext, isTrue);

      final stateLast = DevotionalPlaybackState(
        currentSong: testSong,
        queue: [testSong, testSong],
        currentIndex: 1,
      );
      expect(stateLast.hasPrevious, isTrue);
      expect(stateLast.hasNext, isFalse);
    });
  });
}
