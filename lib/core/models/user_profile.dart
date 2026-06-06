// lib/core/models/user_profile.dart

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final String role; // 'client' or 'driver'
  final double rating;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? vehicleCapacity;
  final int totalDeliveries;
  final int yearsActive;
  final String about;
  final List<DriverReview> reviews;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
    this.rating = 5.0,
    this.vehicleType,
    this.vehiclePlate,
    this.vehicleCapacity,
    this.totalDeliveries = 0,
    this.yearsActive = 1,
    this.about = '',
    this.reviews = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      role: json['role'] ?? 'client',
      rating: (json['rating'] ?? 5.0).toDouble(),
      vehicleType: json['vehicleType'],
      vehiclePlate: json['vehiclePlate'],
      vehicleCapacity: json['vehicleCapacity'],
      totalDeliveries: json['totalDeliveries'] ?? 0,
      yearsActive: json['yearsActive'] ?? 1,
      about: json['about'] ?? '',
      reviews: (json['reviews'] as List?)
              ?.map((e) => DriverReview.fromJson(e))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'role': role,
      'rating': rating,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'vehicleCapacity': vehicleCapacity,
      'totalDeliveries': totalDeliveries,
      'yearsActive': yearsActive,
      'about': about,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
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
      rating: (json['rating'] ?? 5.0).toDouble(),
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
