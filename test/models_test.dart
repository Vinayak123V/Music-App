import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti_music/data/models/rights_management_model.dart';
import 'package:bhakti_music/data/models/song_model.dart';
import 'package:bhakti_music/data/models/category_model.dart';
import 'package:bhakti_music/data/models/deity_model.dart';
import 'package:bhakti_music/core/utils/formatters.dart';

void main() {
  group('RightsManagementModel Tests', () {
    test('Valid non-expired license reports isValidForStreaming = true', () {
      final rights = RightsManagementModel(
        rightsHolder: 'Bhakti Records India',
        licenseReference: 'BM-2026-TEST',
        licenseStartDate: DateTime.now().subtract(const Duration(days: 10)),
        licenseEndDate: DateTime.now().add(const Duration(days: 365)),
        commercialAuthorized: true,
      );

      expect(rights.isExpired, isFalse);
      expect(rights.isValidForStreaming, isTrue);
    });

    test('Expired license reports isExpired = true and isValidForStreaming = false', () {
      final expiredRights = RightsManagementModel(
        rightsHolder: 'Bhakti Records India',
        licenseReference: 'BM-2020-EXPIRED',
        licenseStartDate: DateTime(2020, 1, 1),
        licenseEndDate: DateTime(2021, 1, 1),
        commercialAuthorized: true,
      );

      expect(expiredRights.isExpired, isTrue);
      expect(expiredRights.isValidForStreaming, isFalse);
    });

    test('Serialization and deserialization preserve all fields', () {
      final original = RightsManagementModel(
        rightsHolder: 'Vedic Heritage Trust',
        licenseReference: 'VHT-998',
        permittedTerritories: const ['IN', 'GLOBAL'],
        permittedUsage: 'Worldwide digital devotional streaming',
        commercialAuthorized: true,
      );

      final map = original.toMap();
      final fromMap = RightsManagementModel.fromMap(map);

      expect(fromMap.rightsHolder, original.rightsHolder);
      expect(fromMap.licenseReference, original.licenseReference);
      expect(fromMap.permittedTerritories, original.permittedTerritories);
      expect(fromMap.permittedUsage, original.permittedUsage);
      expect(fromMap.commercialAuthorized, original.commercialAuthorized);
    });
  });

  group('SongModel Tests', () {
    test('Creates SongModel and serializes searchTokens properly', () {
      final now = DateTime.now();
      final song = SongModel(
        id: 'test-shiva-song',
        title: 'Om Namah Shivaya',
        normalizedTitle: 'om namah shivaya',
        artist: 'Anuradha Paudwal',
        categoryId: 'mantras',
        deityId: 'shiva',
        language: 'Sanskrit',
        storagePath: 'audio/test-shiva-song/original.mp3',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      final map = song.toMap();
      expect(map['id'], 'test-shiva-song');
      expect(map['title'], 'Om Namah Shivaya');
      expect(map['searchTokens'], isNotEmpty);
      expect(map['searchTokens'], contains('shiva'));
    });

    test('SongModel.copyWith creates updated instance correctly', () {
      final now = DateTime.now();
      final song = SongModel(
        id: 'test-krishna-song',
        title: 'Hare Krishna',
        normalizedTitle: 'hare krishna',
        artist: 'Traditional',
        categoryId: 'kirtans',
        deityId: 'krishna',
        language: 'Hindi',
        storagePath: 'audio/test-krishna-song/original.mp3',
        published: false,
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      final published = song.copyWith(published: true, featured: true);
      expect(published.published, isTrue);
      expect(published.featured, isTrue);
      expect(song.published, isFalse); // immutable original preserved
    });
  });

  group('Formatters Tests', () {
    test('formatDuration formats mm:ss and hh:mm:ss accurately', () {
      expect(Formatters.formatDuration(null), '--:--');
      expect(Formatters.formatDuration(0), '--:--');
      expect(Formatters.formatDuration(65), '01:05');
      expect(Formatters.formatDuration(3665), '1:01:05');
    });

    test('formatFileSize formats bytes, KB, and MB accurately', () {
      expect(Formatters.formatFileSize(500), '500 B');
      expect(Formatters.formatFileSize(2048), '2.0 KB');
      expect(Formatters.formatFileSize(10485760), '10.00 MB');
    });
  });
}
