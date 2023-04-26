import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/models.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final getUserTweetsProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final getUserDataStreamProvider =
    StreamProvider.autoDispose.family((ref, String uid) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getUserDataStream(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;
  UserProfileController({
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required UserAPI userAPI,
  })  : _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        super(false);

  Future getUserTweets(String uid) async {
    return await _tweetAPI.getUserTweets(uid);
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerPic,
    required File? profilePic,
  }) async {
    state = true;
    if (bannerPic != null) {
      final bannerPicUrl = await _storageAPI.uploadImage(bannerPic);
      userModel = userModel.copyWith(
        bannerPic: bannerPicUrl,
      );
    }

    if (profilePic != null) {
      final profilePicUrl = await _storageAPI.uploadImage(profilePic);
      userModel = userModel.copyWith(
        profilePic: profilePicUrl,
      );
    }

    final res = await _userAPI.updateUserData(userModel);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Navigator.pop(context),
    );
  }
}
