class SearchNormalizer {
  /// Normalize a string by lowercasing, trimming, and replacing multiple spaces
  static String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0900-\u097F]'), '') // Support Devanagari & Latin
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Generate search tokens for Firestore prefix matching
  static List<String> generateSearchTokens(List<String> inputs) {
    final Set<String> tokens = {};

    for (final raw in inputs) {
      final normalized = normalize(raw);
      if (normalized.isEmpty) continue;

      // Add full normalized term
      tokens.add(normalized);

      // Add individual words
      final words = normalized.split(' ');
      for (final word in words) {
        if (word.length >= 2) {
          tokens.add(word);
        }
      }
    }

    return tokens.toList();
  }
}
