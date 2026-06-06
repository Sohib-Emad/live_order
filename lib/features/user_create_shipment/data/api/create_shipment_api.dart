// lib/features/create_shipment/data/api/create_shipment_api.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CreateShipmentApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitShipment(Map<String, dynamic> shipmentData) async {
    final docRef = _firestore.collection('orders').doc();
    shipmentData['id'] = docRef.id;
    await docRef.set(shipmentData);
  }
}
