import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/models.dart';

// final userAPIProvider = Provider((ref) {
//   return FirebaseUserAPI(
//     db: ref.watch(appwriteDatabaseProvider),
//   );
// });

// abstract class IUserAPI {
//   FutureEitherVoid saveUserData(UserModel userModel);
//   Future<Document> getUserData(String uid);
// }

// class FirebaseUserAPI implements IUserAPI {
//   @override
//   Future getUserData(String uid) {
//     // TODO: implement getUserData
//     throw UnimplementedError();
//   }

//   @override
//   FutureEitherVoid saveUserData(UserModel userModel) {
//     // TODO: implement saveUserData
//     throw UnimplementedError();
//   }

// }

// class UserAPI implements IUserAPI {
//   final Databases _db;
//   UserAPI({required Databases db}) : _db = db;
//   @override
//   FutureEitherVoid saveUserData(UserModel userModel) async {
//     try {
//       await _db.createDocument(
//         databaseId: '643d2b0fbdfe980d0f0b',
//         collectionId: '643e6e001e55755b6fd5',
//         documentId: userModel.uid,
//         data: userModel.toMap(),
//       );
//       return right(null);
//     } on AppwriteException catch (e, st) {
//       return left(
//         Failure(e.message ?? 'Some unexpected error occured', st),
//       );
//     } catch (e, st) {
//       return left(
//         Failure(e.toString(), st),
//       );
//     }
//   }

//   @override
//   Future<Document> getUserData(String uid) {
//     return _db.getDocument(
//       databaseId: AppWriteConstants.databaseId,
//       collectionId: AppWriteConstants.usersCollection,
//       documentId: uid,
//     );
//   }
// }
