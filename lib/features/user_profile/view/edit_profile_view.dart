import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/theme/theme.dart';

class EditProfileView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const EditProfileView(),
      );
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return Scaffold(
      body: currentUser == null
          ? const Loader()
          : Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      child: currentUser.bannerPic.isEmpty
                          ? Container(
                              color: Pallete.limeColor,
                            )
                          : Image.network(
                              currentUser.bannerPic,
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
                            image: NetworkImage(currentUser.profilePic),
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
                    // Container(
                    //   alignment: Alignment.bottomRight,
                    //   margin: const EdgeInsets.all(20),
                    //   child: OutlinedButton(
                    //     onPressed: () {},
                    //     style: ElevatedButton.styleFrom(
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20),
                    //       ),
                    //       side: const BorderSide(
                    //         color: Pallete.whiteColor,
                    //         width: 2,
                    //       ),
                    //       padding: const EdgeInsets.symmetric(horizontal: 20),
                    //     ),
                    //     child: Text(
                    //       currentUser.uid == user.uid
                    //           ? 'Edit Profile'
                    //           : 'Follow',
                    //       style: const TextStyle(
                    //         color: Pallete.whiteColor,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
    );
  }
}
