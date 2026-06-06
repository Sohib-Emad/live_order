

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final String role;
  final double rating;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? vehicleCapacity;
  final int totalDeliveries;
  final int yearsActive;
  final String about;
  final List<DriverReview> reviews;
  final bool isVerified;
  final String verificationStatus;
  final String? driverStatus;
  final bool isAvailable;
  double? currentLat;
  double? currentLong;
  final String? nationalId;
  final String? licenseNumber;
  final String idFrontImage;
  final String idBackImage;
  final String licenseImage;
  final String vehicleImage;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  String? get vehicleInfo => vehicleType;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.imageUrl = '',
    required this.role,
    this.rating = 5.0,
    this.vehicleType,
    this.vehiclePlate,
    this.vehicleCapacity,
    this.totalDeliveries = 0,
    this.yearsActive = 1,
    this.about = '',
    this.reviews = const [],
    this.isVerified = false,
    this.verificationStatus = 'unsubmitted',
    this.driverStatus,
    this.isAvailable = true,
    this.currentLat,
    this.currentLong,
    this.nationalId,
    this.licenseNumber,
    this.idFrontImage = '',
    this.idBackImage = '',
    this.licenseImage = '',
    this.vehicleImage = '',
    this.phone,
    this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: (json['uid'] ?? json['user_id'] ?? '') as String,
      name: (json['name'] ?? json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? json['profile_image'] ?? '') as String,
      role: (json['role'] ?? 'client') as String,
      rating: ((json['rating'] as num?)?.toDouble() ?? 5.0),
      vehicleType: _emptyToNull(json['vehicleType'] as String? ?? json['vehicle_type'] as String?),
      vehiclePlate: _emptyToNull(json['vehiclePlate'] as String? ?? json['vehicle_plate'] as String?),
      vehicleCapacity: _emptyToNull(json['vehicleCapacity'] as String? ?? json['vehicle_capacity'] as String?),
      totalDeliveries: (json['totalDeliveries'] as int? ?? json['trips_count'] as int? ?? 0),
      yearsActive: (json['yearsActive'] as int? ?? 1),
      about: (json['about'] ?? '') as String,
      reviews: (json['reviews'] as List?)
              ?.map((e) => DriverReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isVerified: (json['isVerified'] ?? json['is_verified'] ?? false) as bool,
      verificationStatus: _emptyToNull(json['verificationStatus'] as String? ?? json['verification_status'] as String?) ?? 'unsubmitted',
      driverStatus: _emptyToNull(json['driverStatus'] as String? ?? json['driver_status'] as String?),
      isAvailable: (json['isAvailable'] ?? json['is_available'] ?? true) as bool,
      currentLat: (json['currentLat'] as num?)?.toDouble() ?? (json['current_lat'] as num?)?.toDouble(),
      currentLong: (json['currentLong'] as num?)?.toDouble() ?? (json['current_long'] as num?)?.toDouble(),
      nationalId: _emptyToNull(json['nationalId'] as String? ?? json['national_id'] as String?),
      licenseNumber: _emptyToNull(json['licenseNumber'] as String? ?? json['license_number'] as String?),
      idFrontImage: json['idFrontImage'] as String? ?? json['id_front_image'] as String? ?? '',
      idBackImage: json['idBackImage'] as String? ?? json['id_back_image'] as String? ?? '',
      licenseImage: json['licenseImage'] as String? ?? json['license_image'] as String? ?? '',
      vehicleImage: json['vehicleImage'] as String? ?? json['vehicle_image'] as String? ?? '',
      phone: _emptyToNull(json['phone'] as String?),
      address: _emptyToNull(json['address'] as String?),
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'])
          : json['created_at'] != null
              ? _parseDateTime(json['created_at'])
              : DateTime.now(),
    );
  }

  static String? _emptyToNull(String? value) =>
      value == null || value.isEmpty ? null : value;

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'user_id': uid,
      'name': name,
      'username': name,
      'email': email,
      'imageUrl': imageUrl,
      'image_url': imageUrl,
      'role': role,
      'rating': rating,
      'vehicleType': vehicleType,
      'vehicle_type': vehicleType,
      'vehiclePlate': vehiclePlate,
      'vehicle_plate': vehiclePlate,
      'vehicleCapacity': vehicleCapacity,
      'vehicle_capacity': vehicleCapacity,
      'totalDeliveries': totalDeliveries,
      'trips_count': totalDeliveries,
      'yearsActive': yearsActive,
      'about': about,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'isVerified': isVerified,
      'is_verified': isVerified,
      'verificationStatus': verificationStatus,
      'verification_status': verificationStatus,
      'driverStatus': driverStatus,
      'driver_status': driverStatus,
      'isAvailable': isAvailable,
      'is_available': isAvailable,
      'currentLat': currentLat,
      'current_lat': currentLat,
      'currentLong': currentLong,
      'current_long': currentLong,
      'nationalId': nationalId,
      'national_id': nationalId,
      'licenseNumber': licenseNumber,
      'license_number': licenseNumber,
      'idFrontImage': idFrontImage,
      'id_front_image': idFrontImage,
      'idBackImage': idBackImage,
      'id_back_image': idBackImage,
      'licenseImage': licenseImage,
      'license_image': licenseImage,
      'vehicleImage': vehicleImage,
      'vehicle_image': vehicleImage,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? imageUrl,
    String? role,
    double? rating,
    String? vehicleType,
    String? vehiclePlate,
    String? vehicleCapacity,
    int? totalDeliveries,
    int? yearsActive,
    String? about,
    List<DriverReview>? reviews,
    bool? isVerified,
    String? verificationStatus,
    String? driverStatus,
    bool? isAvailable,
    double? currentLat,
    double? currentLong,
    String? nationalId,
    String? licenseNumber,
    String? idFrontImage,
    String? idBackImage,
    String? licenseImage,
    String? vehicleImage,
    String? phone,
    String? address,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleCapacity: vehicleCapacity ?? this.vehicleCapacity,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      yearsActive: yearsActive ?? this.yearsActive,
      about: about ?? this.about,
      reviews: reviews ?? this.reviews,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      driverStatus: driverStatus ?? this.driverStatus,
      isAvailable: isAvailable ?? this.isAvailable,
      currentLat: currentLat ?? this.currentLat,
      currentLong: currentLong ?? this.currentLong,
      nationalId: nationalId ?? this.nationalId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      idFrontImage: idFrontImage ?? this.idFrontImage,
      idBackImage: idBackImage ?? this.idBackImage,
      licenseImage: licenseImage ?? this.licenseImage,
      vehicleImage: vehicleImage ?? this.vehicleImage,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DriverReview {
  final String reviewerName;
  final double rating;
  final String comment;
  final String date;

  DriverReview({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory DriverReview.fromJson(Map<String, dynamic> json) {
    return DriverReview(
      reviewerName: json['reviewerName'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }
}
