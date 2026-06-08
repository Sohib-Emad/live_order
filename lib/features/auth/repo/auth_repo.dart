import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/core/utils/logger.dart';
import 'package:live_order/features/auth/models/auth_model.dart';

class AuthRepo {
  final supabase = SupabaseService.instance.client;
  static const _bucket = 'verification';

  Future<Either<String, String>> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
    String? vehicleType,
    String? vehiclePlate,
    String? vehicleCapacity,
    String? nationalId,
    String? licenseNumber,
    File? driverImage,
    File? idFrontImage,
    File? idBackImage,
    File? licenseImage,
    File? vehicleImage,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final uid = response.user!.id;

      // Insert user row FIRST (before image uploads) so Auth + DB are in sync
      await supabase.from('users').insert({
        'username': username,
        'name': username,
        'email': email,
        'uid': uid,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        if (role == 'driver') ...{
          'driver_status': 'pending',
          'verification_status': 'pending',
          'rating': 5.0,
          'trips_count': 0,
          'is_available': true,
          'current_lat': 30.0444,
          'current_long': 31.2357,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (vehicleType != null && vehicleType.isNotEmpty) 'vehicle_type': vehicleType,
          if (vehiclePlate != null && vehiclePlate.isNotEmpty) 'vehicle_plate': vehiclePlate,
          if (vehicleCapacity != null && vehicleCapacity.isNotEmpty) 'vehicle_capacity': vehicleCapacity,
          if (nationalId != null && nationalId.isNotEmpty) 'national_id': nationalId,
          if (licenseNumber != null && licenseNumber.isNotEmpty) 'license_number': licenseNumber,
        },
        if (address != null && address.isNotEmpty) 'address': address,
      });

      // Upload images after user row is created — failures won't orphan the user
      if (role == 'driver') {
        try {
          if (driverImage != null) {
            final path = '$uid/profile.jpg';
            await supabase.storage.from(_bucket).upload(path, driverImage);
            final url = supabase.storage.from(_bucket).getPublicUrl(path);
            await supabase.from('users').update({'image_url': url}).eq('uid', uid);
          }
          if (idFrontImage != null) {
            final path = '$uid/id_front.jpg';
            await supabase.storage.from(_bucket).upload(path, idFrontImage);
            final url = supabase.storage.from(_bucket).getPublicUrl(path);
            await supabase.from('users').update({'id_front_image': url}).eq('uid', uid);
          }
          if (idBackImage != null) {
            final path = '$uid/id_back.jpg';
            await supabase.storage.from(_bucket).upload(path, idBackImage);
            final url = supabase.storage.from(_bucket).getPublicUrl(path);
            await supabase.from('users').update({'id_back_image': url}).eq('uid', uid);
          }
          if (licenseImage != null) {
            final path = '$uid/license.jpg';
            await supabase.storage.from(_bucket).upload(path, licenseImage);
            final url = supabase.storage.from(_bucket).getPublicUrl(path);
            await supabase.from('users').update({'license_image': url}).eq('uid', uid);
          }
          if (vehicleImage != null) {
            final path = '$uid/vehicle.jpg';
            await supabase.storage.from(_bucket).upload(path, vehicleImage);
            final url = supabase.storage.from(_bucket).getPublicUrl(path);
            await supabase.from('users').update({'vehicle_image': url}).eq('uid', uid);
          }
        } catch (e) {
          // Log but don't fail — user can upload images later
          AppLogger.warning('AuthRepo', 'Image upload failed (non-fatal): $e');
        }
      }

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
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final uid = response.user!.id;

      final userdata = await supabase
          .from('users')
          .select()
          .eq('uid', uid)
          .single();

      // ── Save FCM token ──────────────────────────────────────────────────────
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await supabase
              .from('users')
              .update({'fcm_token': fcmToken})
              .eq('uid', uid);
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
