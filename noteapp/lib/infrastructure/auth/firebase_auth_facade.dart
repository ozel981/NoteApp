// ignore_for_file: library_prefixes

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_firebase_ddd_course/domain/auth/auth_failure.dart';
import 'package:notes_firebase_ddd_course/domain/auth/i_auth_facade.dart';
import 'package:notes_firebase_ddd_course/domain/auth/value_objects.dart';
import 'package:notes_firebase_ddd_course/infrastructure/auth/firebase_user_mapper.dart';
import 'package:notes_firebase_ddd_course/domain/auth/user.dart' as domain;

@LazySingleton(as: IAuthFacade)
class FirebaseAuthFacade implements IAuthFacade {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthFacade(this._firebaseAuth, this._googleSignIn);

  @override
  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  }) async {
    final String emailStr = emailAddress.getOrCrash();
    final String passwordStr = password.getOrCrash();
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: emailStr, password: passwordStr);
      return right(unit);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        return left(const AuthFailure.emailAlreadyInUser());
      } else {
        return left(const AuthFailure.serverError());
      }
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signInWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  }) async {
    final String emailStr = emailAddress.getOrCrash();
    final String passwordStr = password.getOrCrash();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: emailStr, password: passwordStr);
      return right(unit);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        return left(const AuthFailure.invalidEmailAndPasswordCombination());
      } else if (error.code == 'wrong-password') {
        return left(const AuthFailure.invalidEmailAndPasswordCombination());
      } else {
        return left(const AuthFailure.serverError());
      }
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return left(const AuthFailure.cancelledByUser());
      } else {
        final googleAuthentication = await googleUser.authentication;

        final authCredential = GoogleAuthProvider.credential(
            idToken: googleAuthentication.idToken,
            accessToken: googleAuthentication.accessToken);

        return await _firebaseAuth
            .signInWithCredential(authCredential)
            .then((value) => right(unit));
      }
    } on FirebaseAuthException catch (_) {
      return left(const AuthFailure.serverError());
    }
  }

  @override
  Future<Option<domain.User>> getSignedInUser() async =>
      some(_firebaseAuth.currentUser!.toDomain());

  @override
  Future signOut() =>
      Future.wait([_googleSignIn.signOut(), _firebaseAuth.signOut()]);
}
