import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/core/core.dart';

// want signup or want to get user account -> Account
// want to access user related data -> User

final authAPIProvider = Provider((ref) {
  return FirebaseAuthAPI();
});

abstract class IAuthAPI {
  FutureEither<UserCredential> signUp({
    required String email,
    required String password,
  });

  FutureEither<UserCredential> login({
    required String email,
    required String password,
  });
  Future<User?> currentUser();

  Future<void> signOut();
}

class FirebaseAuthAPI implements IAuthAPI {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User?> currentUser() async {
    User? user = _firebaseAuth.currentUser;
    return user;
  }

  @override
  FutureEither<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final account = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return right(account);
    } on FirebaseException catch (e, stackTrace) {
      return left(
          Failure(e.message ?? 'Some unexpected error occured', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final account = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return right(account);
    } on FirebaseException catch (e, stackTrace) {
      return left(
          Failure(e.message ?? 'Some unexpected error occured', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
