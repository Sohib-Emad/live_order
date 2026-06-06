// lib/core/models/shipment.dart

import 'package:live_order/core/models/user_profile.dart';

class Shipment {
  final String id;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final String cargoType; // e.g. Documents, Electronics, Food, Furniture
  final String size; // S, M, L, XL
  final double weight; // kg
  final String notes;
  final List<String> images;
  final String preferredDate;
  final String preferredTimeRange;
  final double priceEstimate;
  final String status; // Waiting Driver, Accepted, In Transit, Delivered, Cancelled
  final UserProfile? assignedDriver;

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
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] ?? '',
      pickupAddress: json['pickupAddress'] ?? '',
      pickupLat: (json['pickupLat'] ?? 0.0).toDouble(),
      pickupLng: (json['pickupLng'] ?? 0.0).toDouble(),
      dropAddress: json['dropAddress'] ?? '',
      dropLat: (json['dropLat'] ?? 0.0).toDouble(),
      dropLng: (json['dropLng'] ?? 0.0).toDouble(),
      cargoType: json['cargoType'] ?? 'Documents',
      size: json['size'] ?? 'M',
      weight: (json['weight'] ?? 1.0).toDouble(),
      notes: json['notes'] ?? '',
      images: List<String>.from(json['images'] ?? const []),
      preferredDate: json['preferredDate'] ?? '',
      preferredTimeRange: json['preferredTimeRange'] ?? '',
      priceEstimate: (json['priceEstimate'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Waiting Driver',
      assignedDriver: json['assignedDriver'] != null
          ? UserProfile.fromJson(json['assignedDriver'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropAddress': dropAddress,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'cargoType': cargoType,
      'size': size,
      'weight': weight,
      'notes': notes,
      'images': images,
      'preferredDate': preferredDate,
      'preferredTimeRange': preferredTimeRange,
      'priceEstimate': priceEstimate,
      'status': status,
      'assignedDriver': assignedDriver?.toJson(),
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
    );
  }
}
