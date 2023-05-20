import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/models.dart';

final tweetAPIProvider = Provider((ref) {
  return TweetAPI();
});

abstract class ITweetAPI {
  FutureEitherVoid shareTweet(TweetModel tweet);
  Future<List<TweetModel>> getTweets();
  Stream<List<TweetModel>> getTweetsStream();
  FutureEither likeTweet(TweetModel tweet);
  FutureEither updateReshareCount(TweetModel tweet);
  Future<List<TweetModel>> getReplies(TweetModel tweet);
  Future<List<TweetModel>> getUserTweets(String uid);
  Future<List<TweetModel>> getTweetsByHashtag(String hashtag);
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
    try {
      await _tweets.doc(tweet.id).set(tweet.toMap());
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
    final tweetsStream = _tweetsStream.map((snapshot) => snapshot.docs
        .map((doc) => TweetModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
    return tweetsStream;
  }

  @override
  FutureEither likeTweet(TweetModel tweet) async {
    try {
      await _tweets.doc(tweet.id).update({
        FirebaseConstants.likes: tweet.likes,
      });
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
  FutureEither updateReshareCount(TweetModel tweet) async {
    try {
      await _tweets.doc(tweet.id).update({
        FirebaseConstants.reshareCount: tweet.reshareCount,
      });
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
  Future<List<TweetModel>> getReplies(TweetModel tweet) async {
    final replies = await _tweets
        .where(FirebaseConstants.repliedTo, isEqualTo: tweet.id)
        .get();
    final List<TweetModel> replyList = [];
    for (final doc in replies.docs) {
      replyList.add(TweetModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    replyList.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
    return replyList;
  }

  @override
  Future<List<TweetModel>> getUserTweets(String uid) async {
    final tweets =
        await _tweets.where(FirebaseConstants.uid, isEqualTo: uid).get();
    final List<TweetModel> tweetList = [];
    for (final doc in tweets.docs) {
      tweetList.add(TweetModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    tweetList.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
    return tweetList;
  }

  @override
  Future<List<TweetModel>> getTweetsByHashtag(String hashtag) async {
    final tweets = await _tweets
        .where(FirebaseConstants.hashtags, arrayContains: hashtag)
        .orderBy(FirebaseConstants.tweetedAt, descending: true)
        .get();
    final List<TweetModel> tweetList = [];
    for (final doc in tweets.docs) {
      tweetList.add(TweetModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    tweetList.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
    return tweetList;
  }
}
