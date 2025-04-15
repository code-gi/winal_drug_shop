class User {
  final int id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final String phone;
  final String address;
  final bool isActive;
  final int orderCount;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.phone,
    this.address = '',
    this.isActive = true,
    this.orderCount = 0,
  });

  // Create a user from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'customer',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      isActive: json['is_active'] ?? true,
      orderCount: json['order_count'] ?? 0,
    );
  }

  // Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'phone': phone,
      'address': address,
      'is_active': isActive,
      'order_count': orderCount,
    };
  }

  // Create a copy of this user with specified fields replaced
  User copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    String? phone,
    String? address,
    bool? isActive,
    int? orderCount,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      orderCount: orderCount ?? this.orderCount,
    );
  }
}
