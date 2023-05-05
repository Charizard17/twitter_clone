import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/models.dart';

final notificationAPIProvider = Provider((ref) {
  return NotificationAPI();
});

abstract class INotificationAPI {
  FutureEitherVoid createNotification(NotificationModel notification);
  Stream<List<NotificationModel>> getNotificationsStream(String uid);
}

class NotificationAPI implements INotificationAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _notifications =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  @override
  FutureEitherVoid createNotification(NotificationModel notification) async {
    try {
      await _notifications.doc(notification.uid).set(notification.toMap());
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
  Stream<List<NotificationModel>> getNotificationsStream(String uid) {
    return _notifications
        .where(FirebaseConstants.uid, isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
