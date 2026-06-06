import 'package:flutter_test/flutter_test.dart';
import 'package:live_order/core/models/shipment.dart';

void main() {
  group('Shipment', () {
    test('smoke: can create a basic Shipment', () {
      final shipment = Shipment(
        id: 's1',
        pickupAddress: '123 Main St',
        pickupLat: 30.0,
        pickupLng: 31.0,
        dropAddress: '456 Elm St',
        dropLat: 30.5,
        dropLng: 31.5,
        cargoType: 'Electronics',
        size: 'M',
        weight: 5.0,
        notes: 'Fragile',
        images: [],
        preferredDate: '2025-06-15',
        preferredTimeRange: '10:00-12:00',
        priceEstimate: 150.0,
        status: 'Waiting Driver',
      );
      expect(shipment.id, 's1');
      expect(shipment.cargoType, 'Electronics');
      expect(shipment.orderName, 'Electronics');
      expect(shipment.size, 'M');
      expect(shipment.priceEstimate, 150.0);
      expect(shipment.status, 'Waiting Driver');
    });

    group('fromJson', () {
      test('parses basic fields with camelCase keys', () {
        final json = {
          'id': 's1',
          'pickupAddress': '123 Main St',
          'pickupLat': 30.0,
          'pickupLng': 31.0,
          'dropAddress': '456 Elm St',
          'dropLat': 30.5,
          'dropLng': 31.5,
          'cargoType': 'Electronics',
          'size': 'L',
          'weight': 12.5,
          'notes': 'Heavy',
          'images': <String>[],
          'preferredDate': '2025-06-15',
          'preferredTimeRange': '10:00-12:00',
          'priceEstimate': 250.0,
          'status': 'Delivered',
          'paymentMethod': 'Card',
          'clientId': 'c1',
          'driverId': 'd1',
        };
        final s = Shipment.fromJson(json);
        expect(s.id, 's1');
        expect(s.pickupAddress, '123 Main St');
        expect(s.pickupLat, 30.0);
        expect(s.pickupLng, 31.0);
        expect(s.dropAddress, '456 Elm St');
        expect(s.dropLat, 30.5);
        expect(s.dropLng, 31.5);
        expect(s.cargoType, 'Electronics');
        expect(s.size, 'L');
        expect(s.weight, 12.5);
        expect(s.notes, 'Heavy');
        expect(s.preferredDate, '2025-06-15');
        expect(s.preferredTimeRange, '10:00-12:00');
        expect(s.priceEstimate, 250.0);
        expect(s.status, 'Delivered');
        expect(s.paymentMethod, 'Card');
        expect(s.clientId, 'c1');
        expect(s.driverId, 'd1');
      });

      test('falls back to old-style order_* fields', () {
        final json = {
          'order_id': 'old-s1',
          'order_name': 'Old Cargo',
          'order_lat': 10.0,
          'order_long': 20.0,
          'user_lat': 10.5,
          'user_long': 20.5,
          'order_size': 'S',
          'order_date': '2025-01-01',
          'order_status': 'Created',
          'order_user_id': 'old-client',
        };
        final s = Shipment.fromJson(json);
        expect(s.id, 'old-s1');
        expect(s.cargoType, 'Old Cargo');
        expect(s.pickupLat, 10.0);
        expect(s.pickupLng, 20.0);
        expect(s.dropLat, 10.5);
        expect(s.dropLng, 20.5);
        expect(s.size, 'S');
        expect(s.preferredDate, '2025-01-01');
        expect(s.status, 'Created');
        expect(s.clientId, 'old-client');
      });

      test('parses rating and review fields', () {
        final json = {
          'id': 's1',
          'pickupAddress': 'Addr',
          'pickupLat': 0.0,
          'pickupLng': 0.0,
          'dropAddress': 'Addr2',
          'dropLat': 1.0,
          'dropLng': 1.0,
          'cargoType': 'T',
          'size': 'M',
          'weight': 1.0,
          'notes': '',
          'images': <String>[],
          'preferredDate': '',
          'preferredTimeRange': '',
          'priceEstimate': 0.0,
          'status': 'Delivered',
          'rating': 4.5,
          'review': 'Great service!',
        };
        final s = Shipment.fromJson(json);
        expect(s.rating, 4.5);
        expect(s.review, 'Great service!');
      });

      test('handles null rating and review', () {
        final json = {
          'id': 's1',
          'pickupAddress': 'A',
          'pickupLat': 0.0,
          'pickupLng': 0.0,
          'dropAddress': 'B',
          'dropLat': 1.0,
          'dropLng': 1.0,
          'cargoType': 'T',
          'size': 'M',
          'weight': 1.0,
          'notes': '',
          'images': <String>[],
          'preferredDate': '',
          'preferredTimeRange': '',
          'priceEstimate': 0.0,
          'status': 'Waiting Driver',
        };
        final s = Shipment.fromJson(json);
        expect(s.rating, isNull);
        expect(s.review, isNull);
      });

      test('parses weight as num and falls back to 1.0', () {
        final json = {
          'id': 's1',
          'pickupAddress': 'A',
          'pickupLat': 0.0,
          'pickupLng': 0.0,
          'dropAddress': 'B',
          'dropLat': 1.0,
          'dropLng': 1.0,
          'cargoType': 'T',
          'size': 'M',
          'images': <String>[],
          'notes': '',
          'preferredDate': '',
          'preferredTimeRange': '',
          'priceEstimate': 0.0,
          'status': 'Waiting Driver',
        };
        final s = Shipment.fromJson(json);
        expect(s.weight, 1.0);
      });
    });

    group('toJson', () {
      test('round-trips correctly', () {
        final original = Shipment(
          id: 's1',
          pickupAddress: '123 Main St',
          pickupLat: 30.0,
          pickupLng: 31.0,
          dropAddress: '456 Elm St',
          dropLat: 30.5,
          dropLng: 31.5,
          cargoType: 'Electronics',
          size: 'M',
          weight: 5.0,
          notes: 'Fragile',
          images: ['img1.jpg'],
          preferredDate: '2025-06-15',
          preferredTimeRange: '10:00-12:00',
          priceEstimate: 150.0,
          status: 'Delivered',
          paymentMethod: 'Card',
          clientId: 'c1',
          driverId: 'd1',
          rating: 4.0,
          review: 'Good',
        );
        final json = original.toJson();
        final restored = Shipment.fromJson(json);
        expect(restored.id, original.id);
        expect(restored.cargoType, original.cargoType);
        expect(restored.size, original.size);
        expect(restored.weight, original.weight);
        expect(restored.notes, original.notes);
        expect(restored.images, original.images);
        expect(restored.preferredDate, original.preferredDate);
        expect(restored.priceEstimate, original.priceEstimate);
        expect(restored.status, original.status);
        expect(restored.paymentMethod, original.paymentMethod);
        expect(restored.clientId, original.clientId);
        expect(restored.driverId, original.driverId);
        expect(restored.rating, original.rating);
        expect(restored.review, original.review);
      });

      test('includes both camelCase and snake_case / order_* keys', () {
        final s = Shipment(
          id: 's1',
          pickupAddress: 'A',
          pickupLat: 1.0,
          pickupLng: 2.0,
          dropAddress: 'B',
          dropLat: 3.0,
          dropLng: 4.0,
          cargoType: 'Cargo',
          size: 'M',
          weight: 1.0,
          notes: '',
          images: [],
          preferredDate: '2025-06-15',
          preferredTimeRange: '',
          priceEstimate: 100.0,
          status: 'Waiting Driver',
        );
        final json = s.toJson();
        expect(json['id'], 's1');
        expect(json['order_id'], 's1');
        expect(json['cargoType'], 'Cargo');
        expect(json['order_name'], 'Cargo');
        expect(json['pickupLat'], 1.0);
        expect(json['order_lat'], 1.0);
        expect(json['status'], 'Waiting Driver');
        expect(json['order_status'], 'Waiting Driver');
      });
    });

    test('copyWith produces independent copy', () {
      final s = Shipment(
        id: 's1',
        pickupAddress: 'A',
        pickupLat: 0.0,
        pickupLng: 0.0,
        dropAddress: 'B',
        dropLat: 1.0,
        dropLng: 1.0,
        cargoType: 'Original',
        size: 'M',
        weight: 1.0,
        notes: '',
        images: [],
        preferredDate: '',
        preferredTimeRange: '',
        priceEstimate: 50.0,
        status: 'Pending',
      );
      final copy = s.copyWith(cargoType: 'Modified', priceEstimate: 200.0);
      expect(copy.cargoType, 'Modified');
      expect(copy.priceEstimate, 200.0);
      expect(s.cargoType, 'Original');
      expect(s.priceEstimate, 50.0);
    });
  });
}
