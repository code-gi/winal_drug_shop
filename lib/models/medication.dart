class Medication {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String type; // 'human' or 'animal'
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

  // Create Medication object from JSON data
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'],
      stock: json['stock'] ?? json['stock_quantity'] ?? 0,
      type: json['type'],
      category: json['category'] ?? json['category_name'] ?? 'Other',
      imageUrl: json['imageUrl'] ?? json['image_url'],
    );
  }

  // Convert Medication object to JSON
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

  // Create a copy of the Medication with updated fields
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
