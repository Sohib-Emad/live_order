import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';

Shipment sampleShipment({
  String? id,
  String? status,
  UserProfile? assignedDriver,
}) {
  return Shipment(
    id: id ?? 'shipment_1',
    pickupAddress: 'شارع الملك فهد، الرياض',
    pickupLat: 24.7136,
    pickupLng: 46.6753,
    dropAddress: 'شارع التحلية، جدة',
    dropLat: 21.5433,
    dropLng: 39.1728,
    cargoType: 'أجهزة إلكترونية',
    size: 'L',
    weight: 15.5,
    notes: 'يرجى الاتصال قبل التوصيل',
    images: const ['https://example.com/img1.jpg'],
    preferredDate: '2026-07-01',
    preferredTimeRange: '10:00 - 14:00',
    priceEstimate: 150.0,
    status: status ?? 'Waiting Driver',
    assignedDriver: assignedDriver,
    paymentMethod: 'عند الاستلام',
    clientId: 'client_1',
    driverId: assignedDriver?.uid ?? '',
  );
}

UserProfile sampleUserProfile({
  String? uid,
  String? role,
}) {
  return UserProfile(
    uid: uid ?? 'driver_1',
    name: 'أحمد محمد',
    email: 'ahmed@example.com',
    imageUrl: 'https://example.com/avatar.jpg',
    role: role ?? 'driver',
    rating: 4.8,
    vehicleType: 'شاحنة صغيرة',
    vehiclePlate: 'ABC 1234',
    vehicleCapacity: '1000 كجم',
    totalDeliveries: 250,
    yearsActive: 3,
    about: 'سائق محترف بخبرة 3 سنوات',
    isVerified: true,
    verificationStatus: 'approved',
    driverStatus: 'available',
    isAvailable: true,
    currentLat: 24.7136,
    currentLong: 46.6753,
    phone: '+966501234567',
    address: 'الرياض، حي العليا',
  );
}

UserProfile sampleClient() {
  return UserProfile(
    uid: 'client_1',
    name: 'سارة أحمد',
    email: 'sara@example.com',
    imageUrl: 'https://example.com/sara.jpg',
    role: 'client',
    rating: 5.0,
    totalDeliveries: 12,
    yearsActive: 1,
    about: '',
    isVerified: false,
    verificationStatus: 'unsubmitted',
    isAvailable: true,
    phone: '+966507654321',
    address: 'جدة، حي الشاطئ',
  );
}

List<Shipment> sampleShipmentList({int count = 3}) {
  return List.generate(count, (i) {
    final driver = UserProfile(
      uid: 'driver_${i + 1}',
      name: 'سائق ${i + 1}',
      email: 'driver${i + 1}@example.com',
      role: 'driver',
      rating: 4.5 + (i * 0.1),
      vehicleType: 'سيارة',
      vehiclePlate: 'XYZ ${1000 + i}',
      totalDeliveries: 50 + (i * 10),
      yearsActive: 1 + i,
      isVerified: true,
      verificationStatus: 'approved',
      isAvailable: true,
    );

    return Shipment(
      id: 'shipment_${i + 1}',
      pickupAddress: 'عنوان الاستلام ${i + 1}',
      pickupLat: 24.71 + (i * 0.01),
      pickupLng: 46.67 + (i * 0.01),
      dropAddress: 'عنوان التوصيل ${i + 1}',
      dropLat: 21.54 + (i * 0.01),
      dropLng: 39.17 + (i * 0.01),
      cargoType: i % 2 == 0 ? 'أجهزة' : 'مواد غذائية',
      size: i % 2 == 0 ? 'M' : 'L',
      weight: 10.0 + (i * 5.0),
      notes: 'ملاحظات الشحنة ${i + 1}',
      images: const [],
      preferredDate: '2026-07-${(i + 1).toString().padLeft(2, '0')}',
      preferredTimeRange: '09:00 - 13:00',
      priceEstimate: 100.0 + (i * 25.0),
      status: i % 2 == 0 ? 'Waiting Driver' : 'In Transit',
      assignedDriver: driver,
      paymentMethod: 'عند الاستلام',
      clientId: 'client_1',
      driverId: driver.uid,
    );
  });
}

List<UserProfile> sampleDriverList({int count = 3}) {
  return List.generate(count, (i) {
    return UserProfile(
      uid: 'driver_${i + 1}',
      name: 'سائق ${i + 1}',
      email: 'driver${i + 1}@example.com',
      imageUrl: 'https://example.com/driver${i + 1}.jpg',
      role: 'driver',
      rating: 4.5 + (i * 0.1),
      vehicleType: i % 2 == 0 ? 'شاحنة' : 'سيارة',
      vehiclePlate: 'ABC ${100 + i}',
      vehicleCapacity: '${500 + (i * 250)} كجم',
      totalDeliveries: 100 + (i * 50),
      yearsActive: 2 + i,
      about: 'سائق ذو خبرة',
      isVerified: true,
      verificationStatus: 'approved',
      driverStatus: 'available',
      isAvailable: true,
      currentLat: 24.71 + (i * 0.02),
      currentLong: 46.67 + (i * 0.02),
      phone: '+96650${1000000 + i}',
      address: 'الرياض، حي ${i + 1}',
    );
  });
}
