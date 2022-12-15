// ignore: library_prefixes
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:notes_firebase_ddd_course/domain/auth/user.dart';
import 'package:notes_firebase_ddd_course/domain/core/value_objects.dart';

extension FirebaseUserDomain on firebase.User {
  User toDomain() => User(id: UniqueId.fromUniqueString(uid));
}
