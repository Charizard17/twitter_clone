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
  FutureEitherVoid saveUserData(UserModel currentUser);
  FutureEitherVoid updateUserData(UserModel currentUser);
  FutureEitherVoid followUser(UserModel user);
  FutureEitherVoid addToFollowing(UserModel currentUser);
  Future getUserData(String uid);
  Stream getUserDataStream(String uid);
  Future<List> searchUserByName(String name);
}

class UserAPI implements IUserAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  Stream<QuerySnapshot> get _usersStream => FirebaseFirestore.instance
      .collection(FirebaseConstants.usersCollection)
      .snapshots();

  @override
  FutureEitherVoid saveUserData(UserModel currentUser) async {
    try {
      await _users.doc(currentUser.uid).set(currentUser.toMap());
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
  FutureEitherVoid updateUserData(UserModel currentUser) async {
    try {
      await _users.doc(currentUser.uid).update(currentUser.toMap());
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
  FutureEitherVoid followUser(UserModel user) async {
    try {
      await _users
          .doc(user.uid)
          .update({FirebaseConstants.followers: user.followers});
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEitherVoid addToFollowing(UserModel currentUser) async {
    try {
      await _users
          .doc(currentUser.uid)
          .update({FirebaseConstants.following: currentUser.following});
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
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

  @override
  Stream getUserDataStream(String uid) {
    final userStream = _users.doc(uid).snapshots().map((snapshot) =>
        UserModel.fromMap(snapshot.data() as Map<String, dynamic>));
    return userStream;
  }
}
