class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role; // client / driver / admin
  final DateTime createdAt;

  // Driver-specific fields
  final String? vehicleInfo;
  final String? driverStatus; // pending / active / blocked
  final double rating; // Driver rating average
  final int tripsCount; // Complete trips count
  final bool isAvailable;
  final double? currentLat;
  final double? currentLong;
  final String? nationalId; // Driver national ID card (14 digits)
  final String? licenseNumber; // Driver driving license number

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.vehicleInfo,
    this.driverStatus,
    this.rating = 5.0,
    this.tripsCount = 0,
    this.isAvailable = true,
    this.currentLat,
    this.currentLong,
    this.nationalId,
    this.licenseNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return UserModel(
      userId: docId ?? json['user_id'] ?? json['uid'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : json['created_at'] != null
              ? (json['created_at'] as dynamic).toDate()
              : DateTime.now(),
      vehicleInfo: json['vehicle_info'],
      driverStatus: json['driver_status'],
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      tripsCount: json['trips_count'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      currentLat: (json['current_lat'] as num?)?.toDouble(),
      currentLong: (json['current_long'] as num?)?.toDouble(),
      nationalId: json['national_id'],
      licenseNumber: json['license_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      if (vehicleInfo != null) 'vehicle_info': vehicleInfo,
      if (driverStatus != null) 'driver_status': driverStatus,
      'rating': rating,
      'trips_count': tripsCount,
      'is_available': isAvailable,
      if (currentLat != null) 'current_lat': currentLat,
      if (currentLong != null) 'current_long': currentLong,
      if (nationalId != null) 'national_id': nationalId,
      if (licenseNumber != null) 'license_number': licenseNumber,
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    String? vehicleInfo,
    String? driverStatus,
    double? rating,
    int? tripsCount,
    bool? isAvailable,
    double? currentLat,
    double? currentLong,
    String? nationalId,
    String? licenseNumber,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      driverStatus: driverStatus ?? this.driverStatus,
      rating: rating ?? this.rating,
      tripsCount: tripsCount ?? this.tripsCount,
      isAvailable: isAvailable ?? this.isAvailable,
      currentLat: currentLat ?? this.currentLat,
      currentLong: currentLong ?? this.currentLong,
      nationalId: nationalId ?? this.nationalId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
    );
  }
}
