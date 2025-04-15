class Category {
  final int id;
  final String name;
  final String description;
  final String type; // 'human' or 'animal'
  final int medicationCount;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.medicationCount = 0,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['medication_type'] ?? json['type'] ?? 'human',
      medicationCount: json['medication_count'] ?? 0,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'medication_type': type,
      'medication_count': medicationCount,
      'image_url': imageUrl,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    int? medicationCount,
    String? imageUrl,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      medicationCount: medicationCount ?? this.medicationCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
