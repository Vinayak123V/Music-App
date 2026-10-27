import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti_music/core/utils/search_normalizer.dart';

void main() {
  group('SearchNormalizer Tests', () {
    test('normalize trims, lowercases and removes punctuation', () {
      expect(SearchNormalizer.normalize('  Shree Hanuman Chalisa!  '), 'shree hanuman chalisa');
      expect(SearchNormalizer.normalize('Maha-Mrityunjaya... Mantra'), 'mahamrityunjaya mantra');
    });

    test('normalize preserves Devanagari Hindi characters', () {
      expect(SearchNormalizer.normalize('  शिव तांडव स्तोत्रम्  '), 'शिव तांडव स्तोत्रम्');
    });

    test('generateSearchTokens generates multi-word and word tokens', () {
      final tokens = SearchNormalizer.generateSearchTokens([
        'Shiva Tandava Stotram',
        'Pt. Hari Prasad',
        'Sanskrit',
      ]);

      expect(tokens, contains('shiva tandava stotram'));
      expect(tokens, contains('shiva'));
      expect(tokens, contains('tandava'));
      expect(tokens, contains('stotram'));
      expect(tokens, contains('sanskrit'));
    });
  });
}
