import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/auth_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/view/login_view.dart';
import 'package:twitter_clone/features/auth/view/signup_view.dart';
import 'package:twitter_clone/features/home/view/home_view.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/constants/constants.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) {
    return AuthController(
      authAPI: ref.watch(authAPIProvider),
      userAPI: ref.watch(userAPIProvider),
    );
  },
);

final currentUserDetailsProvider = FutureProvider((ref) {
  final currentUserUid = ref.watch(currentUserAccountProvider).value!.uid;
  final userDetails = ref.watch(userDetailsProvider(currentUserUid));
  return userDetails.value;
});

final userDetailsProvider = FutureProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

final currentUserAccountProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

class AuthController extends StateNotifier<bool> {
  final FirebaseAuthAPI _authAPI;
  final UserAPI _userAPI;
  AuthController({
    required FirebaseAuthAPI authAPI,
    required UserAPI userAPI,
  })  : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);
  // state = isLoading

  Future<User?> currentUser() => _authAPI.currentUser();

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        UserModel userModel = UserModel(
          username: getNameFromEmail(email),
          name: getNameFromEmail(email),
          followers: const [],
          following: const [],
          profilePic: ExternalConstants.defaultAvatar,
          bannerPic: ExternalConstants.defaultBanner,
          uid: r.user!.uid,
          bio: '',
          isTwitterLime: false,
        );
        final res = await _userAPI.saveUserData(userModel);
        res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Account created! Please login.');
          Navigator.push(context, LoginView.route());
        });
      },
    );
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.login(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => {
        Navigator.push(context, HomeView.route()),
      },
    );
  }

  void signOut({required BuildContext context}) {
    _authAPI.signOut().then(
          (value) => Navigator.push(context, SignUpView.route()),
        );
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    final data = document.data()!;
    final updatedUser = UserModel.fromMap(data);
    return updatedUser;
  }
}
