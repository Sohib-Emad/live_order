import 'package:flutter_test/flutter_test.dart';
import 'package:live_order/core/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('smoke: can create a basic UserProfile', () {
      final user = UserProfile(
        uid: 'u1',
        name: 'Test User',
        email: 'test@example.com',
        role: 'client',
      );
      expect(user.uid, 'u1');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, 'client');
      expect(user.rating, 5.0);
    });

    group('fromJson', () {
      test('parses basic fields', () {
        final json = {
          'uid': 'u1',
          'name': 'Alice',
          'email': 'alice@example.com',
          'imageUrl': '',
          'role': 'client',
          'rating': 4.5,
          'createdAt': '2025-01-01T00:00:00.000',
        };
        final user = UserProfile.fromJson(json);
        expect(user.uid, 'u1');
        expect(user.name, 'Alice');
        expect(user.email, 'alice@example.com');
        expect(user.role, 'client');
        expect(user.rating, 4.5);
      });

      test('falls back to old-style user_id field', () {
        final json = {
          'user_id': 'old-u1',
          'name': 'Bob',
          'email': 'bob@example.com',
          'role': 'driver',
          'created_at': '2025-06-01T00:00:00.000',
        };
        final user = UserProfile.fromJson(json);
        expect(user.uid, 'old-u1');
      });

      test('parses driver-specific fields', () {
        final json = {
          'uid': 'd1',
          'name': 'Driver One',
          'email': 'driver@example.com',
          'role': 'driver',
          'driverStatus': 'active',
          'driver_status': 'active',
          'isAvailable': true,
          'is_available': true,
          'currentLat': 30.0,
          'current_lat': 30.0,
          'currentLong': 31.0,
          'current_long': 31.0,
          'nationalId': '12345678901234',
          'national_id': '12345678901234',
          'licenseNumber': 'LIC-001',
          'license_number': 'LIC-001',
          'vehicleType': 'Truck',
          'vehicle_type': 'Truck',
          'totalDeliveries': 42,
          'trips_count': 42,
          'rating': 4.8,
        };
        final user = UserProfile.fromJson(json);
        expect(user.driverStatus, 'active');
        expect(user.isAvailable, true);
        expect(user.currentLat, 30.0);
        expect(user.currentLong, 31.0);
        expect(user.nationalId, '12345678901234');
        expect(user.licenseNumber, 'LIC-001');
        expect(user.vehicleType, 'Truck');
        expect(user.totalDeliveries, 42);
        expect(user.rating, 4.8);
      });

      test('parses createdAt as String timestamp', () {
        final json = {
          'uid': 'u1',
          'name': 'N',
          'email': 'n@e.com',
          'role': 'client',
          'createdAt': '2024-12-25T10:30:00.000',
        };
        final user = UserProfile.fromJson(json);
        expect(user.createdAt.year, 2024);
        expect(user.createdAt.month, 12);
        expect(user.createdAt.day, 25);
      });

      test('parses createdAt from old-style created_at String', () {
        final json = {
          'uid': 'u1',
          'name': 'N',
          'email': 'n@e.com',
          'role': 'client',
          'created_at': '2023-01-15T08:00:00.000',
        };
        final user = UserProfile.fromJson(json);
        expect(user.createdAt.year, 2023);
        expect(user.createdAt.month, 1);
        expect(user.createdAt.day, 15);
      });

      test('defaults name from username when name missing', () {
        final json = {
          'uid': 'u1',
          'username': 'CoolUser',
          'email': 'u@e.com',
          'role': 'client',
        };
        final user = UserProfile.fromJson(json);
        expect(user.name, 'CoolUser');
      });
    });

    group('toJson', () {
      test('round-trips correctly', () {
        final original = UserProfile(
          uid: 'u1',
          name: 'Alice',
          email: 'a@b.com',
          role: 'driver',
          rating: 4.2,
          isAvailable: false,
          driverStatus: 'active',
        );
        final json = original.toJson();
        final restored = UserProfile.fromJson(json);
        expect(restored.uid, original.uid);
        expect(restored.name, original.name);
        expect(restored.email, original.email);
        expect(restored.role, original.role);
        expect(restored.rating, original.rating);
        expect(restored.isAvailable, original.isAvailable);
        expect(restored.driverStatus, original.driverStatus);
      });

      test('includes both camelCase and snake_case keys', () {
        final user = UserProfile(
          uid: 'u1',
          name: 'Bob',
          email: 'b@b.com',
          role: 'client',
          rating: 3.0,
        );
        final json = user.toJson();
        expect(json['uid'], 'u1');
        expect(json['user_id'], 'u1');
        expect(json['name'], 'Bob');
        expect(json['username'], 'Bob');
        expect(json['rating'], 3.0);
      });
    });

    group('timestamp parsing from Firebase Timestamp', () {
      test('parses DateTime directly', () {
        final now = DateTime(2025, 5, 15, 14, 30);
        final json = {
          'uid': 'u1',
          'name': 'N',
          'email': 'n@e.com',
          'role': 'client',
          'createdAt': now.toIso8601String(),
        };
        final user = UserProfile.fromJson(json);
        expect(user.createdAt.year, 2025);
        expect(user.createdAt.month, 5);
        expect(user.createdAt.day, 15);
      });
    });

    test('copyWith produces independent copy', () {
      final user = UserProfile(
        uid: 'u1',
        name: 'Original',
        email: 'o@o.com',
        role: 'client',
      );
      final copy = user.copyWith(name: 'Modified', rating: 4.0);
      expect(copy.name, 'Modified');
      expect(copy.rating, 4.0);
      expect(user.name, 'Original');
      expect(user.rating, 5.0);
    });

    group('verification fields', () {
      test('defaults to unsubmitted verificationStatus', () {
        final user = UserProfile(
          uid: 'u1',
          name: 'Test',
          email: 't@t.com',
          role: 'driver',
        );
        expect(user.verificationStatus, 'unsubmitted');
        expect(user.idFrontImage, '');
        expect(user.idBackImage, '');
        expect(user.licenseImage, '');
        expect(user.vehicleImage, '');
      });

      test('fromJson parses verification fields', () {
        final json = {
          'uid': 'd1',
          'name': 'Driver',
          'email': 'd@d.com',
          'role': 'driver',
          'verification_status': 'pending',
          'id_front_image': 'https://example.com/id_front.jpg',
          'id_back_image': 'https://example.com/id_back.jpg',
          'license_image': 'https://example.com/license.jpg',
          'vehicle_image': 'https://example.com/vehicle.jpg',
        };
        final user = UserProfile.fromJson(json);
        expect(user.verificationStatus, 'pending');
        expect(user.idFrontImage, 'https://example.com/id_front.jpg');
        expect(user.idBackImage, 'https://example.com/id_back.jpg');
        expect(user.licenseImage, 'https://example.com/license.jpg');
        expect(user.vehicleImage, 'https://example.com/vehicle.jpg');
      });

      test('fromJson falls back to camelCase', () {
        final json = {
          'uid': 'd1',
          'name': 'Driver',
          'email': 'd@d.com',
          'role': 'driver',
          'verificationStatus': 'approved',
          'idFrontImage': 'https://example.com/front.jpg',
          'idBackImage': 'https://example.com/back.jpg',
          'licenseImage': 'https://example.com/lic.jpg',
          'vehicleImage': 'https://example.com/veh.jpg',
        };
        final user = UserProfile.fromJson(json);
        expect(user.verificationStatus, 'approved');
        expect(user.idFrontImage, 'https://example.com/front.jpg');
        expect(user.idBackImage, 'https://example.com/back.jpg');
        expect(user.licenseImage, 'https://example.com/lic.jpg');
        expect(user.vehicleImage, 'https://example.com/veh.jpg');
      });

      test('toJson includes both camelCase and snake_case keys', () {
        final user = UserProfile(
          uid: 'd1',
          name: 'Driver',
          email: 'd@d.com',
          role: 'driver',
          verificationStatus: 'pending',
          idFrontImage: 'https://example.com/f.jpg',
          idBackImage: 'https://example.com/b.jpg',
          licenseImage: 'https://example.com/l.jpg',
          vehicleImage: 'https://example.com/v.jpg',
        );
        final json = user.toJson();
        expect(json['verificationStatus'], 'pending');
        expect(json['verification_status'], 'pending');
        expect(json['idFrontImage'], 'https://example.com/f.jpg');
        expect(json['id_front_image'], 'https://example.com/f.jpg');
        expect(json['idBackImage'], 'https://example.com/b.jpg');
        expect(json['id_back_image'], 'https://example.com/b.jpg');
        expect(json['licenseImage'], 'https://example.com/l.jpg');
        expect(json['license_image'], 'https://example.com/l.jpg');
        expect(json['vehicleImage'], 'https://example.com/v.jpg');
        expect(json['vehicle_image'], 'https://example.com/v.jpg');
      });

      test('copyWith updates verification fields', () {
        final user = UserProfile(
          uid: 'd1',
          name: 'Driver',
          email: 'd@d.com',
          role: 'driver',
        );
        final copy = user.copyWith(
          verificationStatus: 'approved',
          idFrontImage: 'https://example.com/f.jpg',
        );
        expect(copy.verificationStatus, 'approved');
        expect(copy.idFrontImage, 'https://example.com/f.jpg');
        expect(copy.idBackImage, '');
        expect(user.verificationStatus, 'unsubmitted');
        expect(user.idFrontImage, '');
      });
    });
  });
}
