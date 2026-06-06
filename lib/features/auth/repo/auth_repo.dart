import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:live_order/features/auth/models/auth_model.dart';

class AuthRepo {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Either<String, String>> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? vehicleInfo,
    String? nationalId,
    String? licenseNumber,
  }) async {
    try {
      UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestore.collection('users').doc(user.user!.uid).set({
        'username': username,
        'email': email,
        'pass': password,
        'uid': user.user!.uid,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        if (role == 'driver') ...{
          'vehicle_info': vehicleInfo ?? 'سيارة نقل بضائع',
          'driver_status': 'pending',
          'rating': 5.0,
          'trips_count': 0,
          'is_available': true,
          'current_lat': 30.0444,
          'current_long': 31.2357,
          if (nationalId != null) 'national_id': nationalId,
          if (licenseNumber != null) 'license_number': licenseNumber,
        }
      });

      return const Right('success');
    } catch (e) {
      return Left('error: $e');
    }
  }

  Future<Either<String, AuthModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      QuerySnapshot<Map<String, dynamic>> userid = await firestore
          .collection('users')
          .where('uid', isEqualTo: user.user!.uid)
          .get();

      final userdata = userid.docs.first.data();

      // ── Save FCM token ──────────────────────────────────────────────────────
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await firestore
              .collection('users')
              .doc(user.user!.uid)
              .update({'fcm_token': fcmToken});
        }
      } catch (_) {
        // Silently ignore token errors — don't block login
      }
      // ───────────────────────────────────────────────────────────────────────

      return Right(AuthModel.fromJson(userdata));
    } catch (e) {
      return Left('error: $e');
    }
  }
}
