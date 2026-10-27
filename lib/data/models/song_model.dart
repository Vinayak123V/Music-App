import 'rights_management_model.dart';
import '../../core/utils/search_normalizer.dart';

class SongModel {
  final String id;
  final String title;
  final String normalizedTitle;
  final String artist;
  final String categoryId;
  final String deityId;
  final String language;
  final String? description;
  final String? artworkPath;
  final String? artworkUrl;
  final String storagePath;
  final String? audioUrl;
  final int? durationSeconds;
  final bool published;
  final bool featured;
  final List<String> searchTokens;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final RightsManagementModel? rights;

  const SongModel({
    required this.id,
    required this.title,
    required this.normalizedTitle,
    required this.artist,
    required this.categoryId,
    required this.deityId,
    required this.language,
    this.description,
    this.artworkPath,
    this.artworkUrl,
    required this.storagePath,
    this.audioUrl,
    this.durationSeconds,
    this.published = false,
    this.featured = false,
    this.searchTokens = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.rights,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'normalizedTitle': normalizedTitle,
      'artist': artist,
      'categoryId': categoryId,
      'deityId': deityId,
      'language': language,
      'description': description,
      'artworkPath': artworkPath,
      'artworkUrl': artworkUrl,
      'storagePath': storagePath,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'published': published,
      'featured': featured,
      'searchTokens': searchTokens.isNotEmpty
          ? searchTokens
          : SearchNormalizer.generateSearchTokens([title, artist, deityId, categoryId, language]),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'rights': rights?.toMap(),
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawCreatedAt = map['createdAt'];
    final rawUpdatedAt = map['updatedAt'];

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      try {
        // Handle Cloud Firestore Timestamp objects dynamically
        return (val as dynamic).toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    return SongModel(
      id: docId ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Bhajan',
      normalizedTitle: map['normalizedTitle'] as String? ??
          SearchNormalizer.normalize(map['title'] as String? ?? ''),
      artist: map['artist'] as String? ?? 'Traditional',
      categoryId: map['categoryId'] as String? ?? 'bhajans',
      deityId: map['deityId'] as String? ?? 'shiva',
      language: map['language'] as String? ?? 'Hindi',
      description: map['description'] as String?,
      artworkPath: map['artworkPath'] as String?,
      artworkUrl: map['artworkUrl'] as String?,
      storagePath: map['storagePath'] as String? ?? '',
      audioUrl: map['audioUrl'] as String?,
      durationSeconds: map['durationSeconds'] as int?,
      published: map['published'] as bool? ?? false,
      featured: map['featured'] as bool? ?? false,
      searchTokens: List<String>.from(map['searchTokens'] ?? []),
      createdAt: parseDate(rawCreatedAt),
      updatedAt: parseDate(rawUpdatedAt),
      createdBy: map['createdBy'] as String? ?? 'system',
      rights: map['rights'] != null
          ? RightsManagementModel.fromMap(Map<String, dynamic>.from(map['rights']))
          : null,
    );
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? normalizedTitle,
    String? artist,
    String? categoryId,
    String? deityId,
    String? language,
    String? description,
    String? artworkPath,
    String? artworkUrl,
    String? storagePath,
    String? audioUrl,
    int? durationSeconds,
    bool? published,
    bool? featured,
    List<String>? searchTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    RightsManagementModel? rights,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      normalizedTitle: normalizedTitle ?? this.normalizedTitle,
      artist: artist ?? this.artist,
      categoryId: categoryId ?? this.categoryId,
      deityId: deityId ?? this.deityId,
      language: language ?? this.language,
      description: description ?? this.description,
      artworkPath: artworkPath ?? this.artworkPath,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      storagePath: storagePath ?? this.storagePath,
      audioUrl: audioUrl ?? this.audioUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      published: published ?? this.published,
      featured: featured ?? this.featured,
      searchTokens: searchTokens ?? this.searchTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      rights: rights ?? this.rights,
    );
  }
}
