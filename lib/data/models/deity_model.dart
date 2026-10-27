class DeityModel {
  final String id;
  final String name;
  final String slug;
  final String title;
  final String description;
  final String iconName;
  final String? artworkUrl;
  final int sortOrder;

  const DeityModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.title,
    required this.description,
    required this.iconName,
    this.artworkUrl,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'title': title,
      'description': description,
      'iconName': iconName,
      'artworkUrl': artworkUrl,
      'sortOrder': sortOrder,
    };
  }

  factory DeityModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return DeityModel(
      id: docId ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Deity',
      slug: map['slug'] as String? ?? 'deity',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'om',
      artworkUrl: map['artworkUrl'] as String?,
      sortOrder: map['sortOrder'] as int? ?? 1,
    );
  }
}
