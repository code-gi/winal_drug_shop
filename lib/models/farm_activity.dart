class FarmActivity {
  final int id;
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final int duration;
  final String createdAt;
  final String updatedAt;

  FarmActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmActivity.fromJson(Map<String, dynamic> json) {
    return FarmActivity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imagePath: json['image_path'],
      price: json['price'].toDouble(),
      duration: json['duration'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'price': price,
      'duration': duration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Appointment {
  final int id;
  final int userId;
  final int farmActivityId;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final double totalAmount;
  final String paymentStatus;
  final String createdAt;
  final String updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.farmActivityId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['user_id'],
      farmActivityId: json['farm_activity_id'],
      appointmentDate: json['appointment_date'],
      appointmentTime: json['appointment_time'],
      status: json['status'],
      totalAmount: json['total_amount'].toDouble(),
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'farm_activity_id': farmActivityId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'status': status,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}