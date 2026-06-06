class OrderModel {
  final String orderId;
  final String orderName;
  final double orderLat;
  final double orderLong;
  final double userLat;
  final double userLong;
  final String orderUserId;
  final String orderDate;
  final String orderStatus;
  
  // New Cargo Marketplace fields
  final String orderSize; // small / medium / large
  final String driverId; // Selected Driver UID
  final double? rating; // Client rating (1.0 to 5.0)
  final String? review; // Client review text

  OrderModel({
    required this.orderId,
    required this.orderName,
    required this.orderLat,
    required this.orderLong,
    required this.userLat,
    required this.userLong,
    required this.orderUserId,
    required this.orderDate,
    required this.orderStatus,
    this.orderSize = 'medium',
    this.driverId = '',
    this.rating,
    this.review,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return OrderModel(
      orderId: docId ?? json['order_id'] ?? '',
      orderName: json['order_name'] ?? '',
      orderLat: (json['order_lat'] as num?)?.toDouble() ?? 0.0,
      orderLong: (json['order_long'] as num?)?.toDouble() ?? 0.0,
      userLat: (json['user_lat'] as num?)?.toDouble() ?? 0.0,
      userLong: (json['user_long'] as num?)?.toDouble() ?? 0.0,
      orderUserId: json['order_user_id'] ?? '',
      orderDate: json['order_date'] ?? '',
      orderStatus: json['order_status'] ?? 'Created',
      orderSize: json['order_size'] ?? 'medium',
      driverId: json['driver_id'] ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      review: json['review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_name': orderName,
      'order_lat': orderLat,
      'order_long': orderLong,
      'user_lat': userLat,
      'user_long': userLong,
      'order_user_id': orderUserId,
      'order_date': orderDate,
      'order_status': orderStatus,
      'order_size': orderSize,
      'driver_id': driverId,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
    };
  }

  OrderModel copyWith({
    String? orderId,
    String? orderName,
    double? orderLat,
    double? orderLong,
    double? userLat,
    double? userLong,
    String? orderUserId,
    String? orderDate,
    String? orderStatus,
    String? orderSize,
    String? driverId,
    double? rating,
    String? review,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      orderName: orderName ?? this.orderName,
      orderLat: orderLat ?? this.orderLat,
      orderLong: orderLong ?? this.orderLong,
      userLat: userLat ?? this.userLat,
      userLong: userLong ?? this.userLong,
      orderUserId: orderUserId ?? this.orderUserId,
      orderDate: orderDate ?? this.orderDate,
      orderStatus: orderStatus ?? this.orderStatus,
      orderSize: orderSize ?? this.orderSize,
      driverId: driverId ?? this.driverId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}
