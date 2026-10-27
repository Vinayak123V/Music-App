class UserProfileModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool isAdmin;
  final String preferredLanguage;
  final List<String> favoriteSongIds;
  final List<String> recentSongIds;

  const UserProfileModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.isAdmin = false,
    this.preferredLanguage = 'All',
    this.favoriteSongIds = const [],
    this.recentSongIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isAdmin': isAdmin,
      'preferredLanguage': preferredLanguage,
      'favoriteSongIds': favoriteSongIds,
      'recentSongIds': recentSongIds,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map, [String? uid]) {
    return UserProfileModel(
      uid: uid ?? map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      isAdmin: map['isAdmin'] as bool? ?? false,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'All',
      favoriteSongIds: List<String>.from(map['favoriteSongIds'] ?? []),
      recentSongIds: List<String>.from(map['recentSongIds'] ?? []),
    );
  }

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isAdmin,
    String? preferredLanguage,
    List<String>? favoriteSongIds,
    List<String>? recentSongIds,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAdmin: isAdmin ?? this.isAdmin,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      favoriteSongIds: favoriteSongIds ?? this.favoriteSongIds,
      recentSongIds: recentSongIds ?? this.recentSongIds,
    );
  }
}
