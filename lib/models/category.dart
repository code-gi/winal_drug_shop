class Category {
  final int id;
  final String name;
  final String description;
  final String type; // 'human' or 'animal'
  final int medicationCount;
  final String? imageUrl; // Added imageUrl property

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.medicationCount = 0,
    this.imageUrl,
  });

  // Create a category from JSON data
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'human',
      medicationCount: json['medication_count'] ?? 0,
      imageUrl: json['image_url'],
    );
  }

  // Convert category to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'medication_count': medicationCount,
      'image_url': imageUrl,
    };
  }

  // Create a copy of this category with specified fields replaced
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
