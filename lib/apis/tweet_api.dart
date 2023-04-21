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
  Future<List<TweetModel>> getTweets();
  Stream<List<TweetModel>> getTweetsStream();
}

class TweetAPI implements ITweetAPI {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference get _tweets =>
      _firestore.collection(FirebaseConstants.tweetsCollection);
  Stream<QuerySnapshot> get _tweetsStream => FirebaseFirestore.instance
      .collection(FirebaseConstants.tweetsCollection)
      .orderBy(FirebaseConstants.tweetedAt, descending: true)
      .snapshots();

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

  @override
  Future<List<TweetModel>> getTweets() async {
    final tweets = await _tweets
        .orderBy(FirebaseConstants.tweetedAt, descending: true)
        .get();
    final List<TweetModel> tweetList = [];
    for (final doc in tweets.docs) {
      tweetList.add(TweetModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return tweetList;
  }

  @override
  Stream<List<TweetModel>> getTweetsStream() {
    return _tweetsStream.map((snapshot) => snapshot.docs
        .map((doc) => TweetModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }
}
