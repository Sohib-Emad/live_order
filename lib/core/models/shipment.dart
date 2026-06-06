import 'package:live_order/core/models/user_profile.dart';

class Shipment {
  final String id;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final String cargoType;
  final String size;
  final double weight;
  final String notes;
  final List<String> images;
  final String preferredDate;
  final String preferredTimeRange;
  final double priceEstimate;
  final String status;
  final UserProfile? assignedDriver;
  final String paymentMethod;
  final String clientId;
  final String driverId;
  final double? rating;
  final String? review;

  String get orderName => cargoType;

  Shipment({
    required this.id,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.cargoType,
    required this.size,
    required this.weight,
    required this.notes,
    required this.images,
    required this.preferredDate,
    required this.preferredTimeRange,
    required this.priceEstimate,
    required this.status,
    this.assignedDriver,
    this.paymentMethod = 'عند الاستلام',
    this.clientId = '',
    this.driverId = '',
    this.rating,
    this.review,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: (json['id'] ?? json['order_id'] ?? '') as String,
      pickupAddress: (json['pickupAddress'] ?? json['pickup_address'] ?? '') as String,
      pickupLat: (json['pickupLat'] ?? json['pickup_lat'] ?? json['order_lat'] ?? 0.0).toDouble(),
      pickupLng: (json['pickupLng'] ?? json['pickup_lng'] ?? json['order_long'] ?? 0.0).toDouble(),
      dropAddress: (json['dropAddress'] ?? json['drop_address'] ?? '') as String,
      dropLat: (json['dropLat'] ?? json['drop_lat'] ?? json['user_lat'] ?? 0.0).toDouble(),
      dropLng: (json['dropLng'] ?? json['drop_lng'] ?? json['user_long'] ?? 0.0).toDouble(),
      cargoType: (json['cargoType'] ?? json['cargo_type'] ?? json['order_name'] ?? '') as String,
      size: (json['size'] ?? json['order_size'] ?? 'M') as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      notes: (json['notes'] ?? '') as String,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      preferredDate: (json['preferredDate'] ?? json['preferred_date'] ?? json['order_date'] ?? '') as String,
      preferredTimeRange: (json['preferredTimeRange'] ?? json['preferred_time_range'] ?? '') as String,
      priceEstimate: (json['priceEstimate'] ?? json['price_estimate'] ?? 0.0).toDouble(),
      status: (json['status'] ?? json['order_status'] ?? 'Waiting Driver') as String,
      assignedDriver: (json['assignedDriver'] ?? json['assigned_driver']) != null
          ? UserProfile.fromJson((json['assignedDriver'] ?? json['assigned_driver']) as Map<String, dynamic>)
          : null,
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'] ?? 'عند الاستلام') as String,
      clientId: (json['clientId'] ?? json['client_id'] ?? json['order_user_id'] ?? '') as String,
      driverId: (json['driverId'] ?? json['driver_id'] ?? '') as String,
      rating: (json['rating'] as num?)?.toDouble(),
      review: json['review'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': id,
      'pickupAddress': pickupAddress,
      'pickup_address': pickupAddress,
      'pickupLat': pickupLat,
      'pickup_lat': pickupLat,
      'order_lat': pickupLat,
      'pickupLng': pickupLng,
      'pickup_lng': pickupLng,
      'order_long': pickupLng,
      'dropAddress': dropAddress,
      'drop_address': dropAddress,
      'dropLat': dropLat,
      'drop_lat': dropLat,
      'user_lat': dropLat,
      'dropLng': dropLng,
      'drop_lng': dropLng,
      'user_long': dropLng,
      'cargoType': cargoType,
      'cargo_type': cargoType,
      'order_name': cargoType,
      'size': size,
      'order_size': size,
      'weight': weight,
      'notes': notes,
      'images': images,
      'preferredDate': preferredDate,
      'preferred_date': preferredDate,
      'order_date': preferredDate,
      'preferredTimeRange': preferredTimeRange,
      'preferred_time_range': preferredTimeRange,
      'priceEstimate': priceEstimate,
      'price_estimate': priceEstimate,
      'status': status,
      'order_status': status,
      'assignedDriver': assignedDriver?.toJson(),
      'paymentMethod': paymentMethod,
      'payment_method': paymentMethod,
      'clientId': clientId,
      'client_id': clientId,
      'order_user_id': clientId,
      'driverId': driverId,
      'driver_id': driverId,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
    };
  }

  Shipment copyWith({
    String? id,
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    String? dropAddress,
    double? dropLat,
    double? dropLng,
    String? cargoType,
    String? size,
    double? weight,
    String? notes,
    List<String>? images,
    String? preferredDate,
    String? preferredTimeRange,
    double? priceEstimate,
    String? status,
    UserProfile? assignedDriver,
    String? paymentMethod,
    String? clientId,
    String? driverId,
    double? rating,
    String? review,
  }) {
    return Shipment(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropAddress: dropAddress ?? this.dropAddress,
      dropLat: dropLat ?? this.dropLat,
      dropLng: dropLng ?? this.dropLng,
      cargoType: cargoType ?? this.cargoType,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      images: images ?? this.images,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTimeRange: preferredTimeRange ?? this.preferredTimeRange,
      priceEstimate: priceEstimate ?? this.priceEstimate,
      status: status ?? this.status,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      clientId: clientId ?? this.clientId,
      driverId: driverId ?? this.driverId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}
