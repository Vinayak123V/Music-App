import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/local_storage_service.dart';
import 'favorites_providers.dart';

class PreferredLanguageNotifier extends StateNotifier<String> {
  final LocalStorageService _storage;

  PreferredLanguageNotifier(this._storage) : super(_storage.getPreferredLanguage());

  Future<void> setLanguage(String lang) async {
    await _storage.setPreferredLanguage(lang);
    state = lang;
  }
}

final preferredLanguageProvider = StateNotifierProvider<PreferredLanguageNotifier, String>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return PreferredLanguageNotifier(storage);
});
