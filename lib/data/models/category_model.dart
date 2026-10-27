class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String type;
  final String? artworkPath;
  final String? artworkUrl;
  final int sortOrder;
  final bool enabled;
  final String? description;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    this.artworkPath,
    this.artworkUrl,
    required this.sortOrder,
    this.enabled = true,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'type': type,
      'artworkPath': artworkPath,
      'artworkUrl': artworkUrl,
      'sortOrder': sortOrder,
      'enabled': enabled,
      'description': description,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return CategoryModel(
      id: docId ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Category',
      slug: map['slug'] as String? ?? 'category',
      type: map['type'] as String? ?? 'general',
      artworkPath: map['artworkPath'] as String?,
      artworkUrl: map['artworkUrl'] as String?,
      sortOrder: map['sortOrder'] as int? ?? 1,
      enabled: map['enabled'] as bool? ?? true,
      description: map['description'] as String?,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? type,
    String? artworkPath,
    String? artworkUrl,
    int? sortOrder,
    bool? enabled,
    String? description,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      type: type ?? this.type,
      artworkPath: artworkPath ?? this.artworkPath,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      enabled: enabled ?? this.enabled,
      description: description ?? this.description,
    );
  }
}
