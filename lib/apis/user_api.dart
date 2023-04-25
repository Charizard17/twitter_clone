import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userAPIProvider = Provider((ref) {
  return UserAPI();
});

abstract class IUserAPI {
  FutureEitherVoid saveUserData(UserModel userModel);
  FutureEitherVoid updateUserData(UserModel userModel);
  Future getUserData(String uid);
  Future<List> searchUserByName(String name);
}

class UserAPI implements IUserAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      await _users.doc(userModel.uid).set(userModel.toMap());
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(
        Failure(e.message ?? 'Some unexpected error occured', st),
      );
    } catch (e, st) {
      return left(
        Failure(e.toString(), st),
      );
    }
  }

  @override
  FutureEitherVoid updateUserData(UserModel userModel) async {
    try {
      await _users.doc(userModel.uid).update(userModel.toMap());
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(
        Failure(e.message ?? 'Some unexpected error occured', st),
      );
    } catch (e, st) {
      return left(
        Failure(e.toString(), st),
      );
    }
  }

  @override
  Future getUserData(String uid) async {
    return _users.doc(uid).get();
  }

  @override
  Future<List<UserModel>> searchUserByName(String name) async {
    final users = await _users
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: '${name}z')
        .get();
    final List<UserModel> userList = [];
    for (final doc in users.docs) {
      userList.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return userList;
  }
}
