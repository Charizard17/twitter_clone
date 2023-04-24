import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/user_profile/view/edit_profile_view.dart';
import 'package:twitter_clone/features/user_profile/widgets/follow_count.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:twitter_clone/theme/theme.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return SafeArea(
      child: currentUser == null
          ? const Loader()
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          child: user.bannerPic.isEmpty
                              ? Container(
                                  color: Pallete.limeColor,
                                )
                              : Image.network(
                                  user.bannerPic,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              color: Pallete.backgroundColor,
                              image: DecorationImage(
                                image: NetworkImage(user.profilePic),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                              border: Border.all(
                                color: Pallete.backgroundColor,
                                width: 5,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          margin: const EdgeInsets.all(20),
                          child: OutlinedButton(
                            onPressed: () {
                              if (currentUser.uid == user.uid) {
                                Navigator.push(
                                  context,
                                  EditProfileView.route(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Pallete.whiteColor,
                                width: 2,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Text(
                              currentUser.uid == user.uid
                                  ? 'Edit Profile'
                                  : 'Follow',
                              style: const TextStyle(
                                color: Pallete.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${user.username}',
                            style: const TextStyle(
                              fontSize: 17,
                              color: Pallete.greyColor,
                            ),
                          ),
                          Text(
                            user.bio,
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              FollowCount(
                                count: user.following.length,
                                text: 'Following',
                              ),
                              const SizedBox(width: 20),
                              FollowCount(
                                count: user.followers.length,
                                text: 'Followers',
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Divider(color: Pallete.greyColor)
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: ref.watch(getUserTweetsProvider(user.uid)).when(
                  data: (tweets) {
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        return TweetCard(tweet: tweet);
                      },
                    );
                  },
                  error: (error, st) => ErrorText(
                        error: error.toString(),
                      ),
                  loading: () => const Loader()),
            ),
    );
  }
}
