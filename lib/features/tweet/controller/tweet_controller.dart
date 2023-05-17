import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:uuid/uuid.dart';

final tweetControllerProvider = StateNotifierProvider<TweetController, bool>(
  (ref) {
    return TweetController(
      ref: ref,
      tweetAPI: ref.watch(tweetAPIProvider),
      storageAPI: ref.watch(storageAPIProvider),
      userAPI: ref.watch(userAPIProvider),
      notificationController:
          ref.watch(notificationControllerProvider.notifier),
    );
  },
);

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getRepliesProvider = FutureProvider.family((ref, TweetModel tweet) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getReplies(tweet);
});

final getTweetsStreamProvider = StreamProvider.autoDispose((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getTweetsStream();
});

final getUsernameProvider = FutureProvider.family((ref, String uid) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getUsernameFromUid(uid);
});

class TweetController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;
  final NotificationController _notificationController;
  final Ref _ref;
  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required UserAPI userAPI,
    required NotificationController notificationController,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<TweetModel>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList;
  }

  void likeTweet(TweetModel tweet, UserModel currentUser) async {
    List<String> likes = tweet.likes;

    if (tweet.likes.contains(currentUser.uid)) {
      likes.remove(currentUser.uid);
    } else {
      likes.add(currentUser.uid);
    }

    tweet = tweet.copyWith(
      likes: likes,
    );
    final res = await _tweetAPI.likeTweet(tweet);
    res.fold((l) => null, (r) {
      _notificationController.createNotification(
        text: '${currentUser.name} liked your tweet!',
        postId: tweet.id,
        notificationType: NotificationType.like,
        uid: tweet.uid,
      );
    });
  }

  void reshareTweet(
    TweetModel tweet,
    UserModel currentUser,
    BuildContext context,
  ) async {
    tweet = tweet.copyWith(
      retweetedBy: currentUser.username,
      likes: [],
      commentIds: [],
      reshareCount: tweet.reshareCount + 1,
    );
    final res = await _tweetAPI.updateReshareCount(tweet);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        final uuid = const Uuid().v1();
        tweet = tweet.copyWith(
          id: uuid,
          reshareCount: 0,
        );
        final res2 = await _tweetAPI.shareTweet(tweet);
        res2.fold((l) => showSnackBar(context, l.message), (r) {
          _notificationController.createNotification(
            text: '${currentUser.name} reshared your tweet!',
            postId: tweet.id,
            notificationType: NotificationType.retweet,
            uid: tweet.uid,
          );
          showSnackBar(context, 'Retweeted!');
        });
      },
    );
  }

  void shareTweet({
    required BuildContext context,
    required List<File> images,
    required String text,
    required String repliedTo,
    required String repliedToUserId,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, 'Please enter text');
      return;
    }

    if (images.isNotEmpty) {
      _shareImageTweet(
          images: images,
          text: text,
          repliedTo: repliedTo,
          context: context,
          repliedToUserId: repliedToUserId);
    } else {
      _shareTextTweet(
          text: text,
          repliedTo: repliedTo,
          context: context,
          repliedToUserId: repliedToUserId);
    }
  }

  Future<List<TweetModel>> getReplies(TweetModel tweet) async {
    final tweetList = await _tweetAPI.getReplies(tweet);
    return tweetList;
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required String repliedTo,
    required String repliedToUserId,
    required BuildContext context,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    final String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinks = await _storageAPI.uploadImages(images);
    TweetModel tweet = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imageLinks,
      uid: user.uid,
      tweetType: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      retweetedBy: '',
      repliedTo: repliedTo,
    );
    final res = await _tweetAPI.shareTweet(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedToUserId.isNotEmpty) {
        _notificationController.createNotification(
          text: '${user.name} replied to your tweet!',
          postId: tweet.id,
          notificationType: NotificationType.retweet,
          uid: tweet.uid,
        );
      }
    });
    state = false;
  }

  void _shareTextTweet({
    required String text,
    required String repliedTo,
    required String repliedToUserId,
    required BuildContext context,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    final String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final uuid = const Uuid().v1();
    TweetModel tweet = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: const [],
      uid: user.uid,
      tweetType: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: uuid,
      reshareCount: 0,
      retweetedBy: '',
      repliedTo: repliedTo,
    );
    final res = await _tweetAPI.shareTweet(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedToUserId.isNotEmpty) {
        _notificationController.createNotification(
          text: '${user.name} replied to your tweet!',
          postId: tweet.id,
          notificationType: NotificationType.retweet,
          uid: tweet.uid,
        );
      }
    });
    state = false;
  }

  String _getLinkFromText(String text) {
    String link = '';
    List<String> wordsInSentence = text.split(' ');
    for (String word in wordsInSentence) {
      if (word.startsWith('https://') || word.startsWith('www.')) {
        link = word;
      }
    }
    return link;
  }

  List<String> _getHashtagsFromText(String text) {
    List<String> hashtags = [];
    List<String> wordsInSentence = text.split(' ');
    for (String word in wordsInSentence) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }
    return hashtags;
  }

  Future<String> getUsernameFromUid(String uid) async {
    final document = await _userAPI.getUserData(uid);
    final data = document.data()!;
    final user = UserModel.fromMap(data);
    return user.username;
  }
}
