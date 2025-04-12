class Medication {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String type;
  final String category;
  final String? imageUrl;

  Medication({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.type,
    required this.category,
    this.imageUrl,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] ?? json['stock_quantity'] ?? 0) as int,
      type: json['medication_type'] ?? json['type'] ?? 'human',
      category: json['category_name'] ?? json['category'] ?? 'Other',
      imageUrl: json['image_url'] ?? json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'type': type,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  Medication copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? type,
    String? category,
    String? imageUrl,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      type: type ?? this.type,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
