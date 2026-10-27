class PlaylistModel {
  final String id;
  final String title;
  final String? description;
  final String? artworkPath;
  final String? artworkUrl;
  final List<String> songIds;
  final String language;
  final bool published;
  final DateTime createdAt;

  const PlaylistModel({
    required this.id,
    required this.title,
    this.description,
    this.artworkPath,
    this.artworkUrl,
    this.songIds = const [],
    this.language = 'Hindi',
    this.published = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'artworkPath': artworkPath,
      'artworkUrl': artworkUrl,
      'songIds': songIds,
      'language': language,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawDate = map['createdAt'];
    DateTime parsedDate = DateTime.now();
    if (rawDate != null) {
      if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else {
        try {
          parsedDate = (rawDate as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
    }

    return PlaylistModel(
      id: docId ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Playlist',
      description: map['description'] as String?,
      artworkPath: map['artworkPath'] as String?,
      artworkUrl: map['artworkUrl'] as String?,
      songIds: List<String>.from(map['songIds'] ?? []),
      language: map['language'] as String? ?? 'Hindi',
      published: map['published'] as bool? ?? true,
      createdAt: parsedDate,
    );
  }

  PlaylistModel copyWith({
    String? id,
    String? title,
    String? description,
    String? artworkPath,
    String? artworkUrl,
    List<String>? songIds,
    String? language,
    bool? published,
    DateTime? createdAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      artworkPath: artworkPath ?? this.artworkPath,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      songIds: songIds ?? this.songIds,
      language: language ?? this.language,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
