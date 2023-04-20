import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:uuid/uuid.dart';

final tweetAPIProvider = Provider((ref) {
  return TweetAPI();
});

abstract class ITweetAPI {
  FutureEitherVoid shareTweet(TweetModel tweet);
}

class TweetAPI implements ITweetAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _tweets =>
      _firestore.collection(FirebaseConstants.tweetsCollection);

  @override
  FutureEitherVoid shareTweet(TweetModel tweet) async {
    final uuid = Uuid();
    try {
      await _tweets.doc(uuid.v1()).set(tweet.toMap());
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
}
