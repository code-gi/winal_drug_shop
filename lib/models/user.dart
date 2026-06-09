class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime createdAt;
  final String phone;
  final String address;
  final bool isActive;
  final int orderCount;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
    required this.phone,
    this.address = '',
    this.isActive = true,
    this.orderCount = 0,
  });

  String get name => '$firstName $lastName'.trim();

  // Create a user from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    final fullName = (json['name'] ?? '').toString().trim();
    final parsedNameParts =
        fullName.isNotEmpty ? fullName.split(RegExp(r'\s+')) : [];

    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: (json['first_name'] ?? json['firstName'] ??
              (parsedNameParts.isNotEmpty ? parsedNameParts.first : ''))
          .toString(),
      lastName: (json['last_name'] ?? json['lastName'] ??
              (parsedNameParts.length > 1
                  ? parsedNameParts.sublist(1).join(' ')
                  : ''))
          .toString(),
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
      'first_name': firstName,
      'last_name': lastName,
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
    String? firstName,
    String? lastName,
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
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      orderCount: orderCount ?? this.orderCount,
    );
  }
}
