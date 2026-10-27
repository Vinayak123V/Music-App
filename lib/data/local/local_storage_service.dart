import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyFavorites = 'bhakti_favorites';
  static const String _keyRecents = 'bhakti_recents';
  static const String _keyLanguage = 'bhakti_preferred_language';
  static const String _keyPersonalPlaylists = 'bhakti_personal_playlists';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // Favorites
  List<String> getFavorites() {
    return _prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> toggleFavorite(String songId) async {
    final list = getFavorites();
    if (list.contains(songId)) {
      list.remove(songId);
    } else {
      list.insert(0, songId);
    }
    await _prefs.setStringList(_keyFavorites, list);
  }

  bool isFavorite(String songId) {
    return getFavorites().contains(songId);
  }

  // Recents
  List<String> getRecentlyPlayed() {
    return _prefs.getStringList(_keyRecents) ?? [];
  }

  Future<void> addRecentlyPlayed(String songId) async {
    final list = getRecentlyPlayed();
    list.remove(songId);
    list.insert(0, songId);
    // Keep last 30 tracks
    if (list.length > 30) {
      list.removeRange(30, list.length);
    }
    await _prefs.setStringList(_keyRecents, list);
  }

  // Preferred Language
  String getPreferredLanguage() {
    return _prefs.getString(_keyLanguage) ?? 'All';
  }

  Future<void> setPreferredLanguage(String lang) async {
    await _prefs.setString(_keyLanguage, lang);
  }

  // Personal Playlists
  List<Map<String, dynamic>> getPersonalPlaylists() {
    final raw = _prefs.getString(_keyPersonalPlaylists);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePersonalPlaylists(List<Map<String, dynamic>> playlists) async {
    await _prefs.setString(_keyPersonalPlaylists, jsonEncode(playlists));
  }
}
