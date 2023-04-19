import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String uid;
  final String name;
  final String profilePic;
  final String bannerPic;
  final String bio;
  final List<String> followers;
  final List<String> following;
  final bool isTwitterLime;
  UserModel({
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.bannerPic,
    required this.bio,
    required this.followers,
    required this.following,
    required this.isTwitterLime,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? profilePic,
    String? bannerPic,
    String? bio,
    List<String>? followers,
    List<String>? following,
    bool? isTwitterLime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      bannerPic: bannerPic ?? this.bannerPic,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isTwitterLime: isTwitterLime ?? this.isTwitterLime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'profilePic': profilePic,
      'bannerPic': bannerPic,
      'bio': bio,
      'followers': followers,
      'following': following,
      'isTwitterLime': isTwitterLime,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      bannerPic: map['bannerPic'] ?? '',
      bio: map['bio'] ?? '',
      followers: List<String>.from((map['followers'])),
      following: List<String>.from((map['following'])),
      isTwitterLime: map['isTwitterLime'] ?? false,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, profilePic: $profilePic, bannerPic: $bannerPic, bio: $bio, followers: $followers, following: $following, isTwitterLime: $isTwitterLime)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.bannerPic == bannerPic &&
        other.bio == bio &&
        listEquals(other.followers, followers) &&
        listEquals(other.following, following) &&
        other.isTwitterLime == isTwitterLime;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        profilePic.hashCode ^
        bannerPic.hashCode ^
        bio.hashCode ^
        followers.hashCode ^
        following.hashCode ^
        isTwitterLime.hashCode;
  }
}
