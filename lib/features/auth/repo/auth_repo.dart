import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:live_order/features/auth/models/auth_model.dart';

class AuthRepo {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Either<String, String>> register({
    required String username,
    required String email,
    required String password,
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
      return Right(AuthModel.fromJson(userdata));
    } catch (e) {
      return Left('error: $e');
    }
  }
}
