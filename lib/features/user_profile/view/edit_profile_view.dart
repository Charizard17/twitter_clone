import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
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
  late TextEditingController nameController;
  late TextEditingController bioController;
  File? bannerPicFile;
  File? profilePicFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: ref.read(currentUserDetailsProvider).value?.name ?? '',
    );
    bioController = TextEditingController(
      text: ref.read(currentUserDetailsProvider).value?.bio ?? '',
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
  }

  void selectBannerImage() async {
    final bannerImage = await pickImage();
    if (bannerImage != null) {
      setState(() {
        bannerPicFile = bannerImage;
      });
    }
  }

  void selectProfileImage() async {
    final profileImage = await pickImage();
    if (profileImage != null) {
      setState(() {
        profilePicFile = profileImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(userProfileControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(userProfileControllerProvider.notifier)
                  .updateUserProfile(
                    userModel: currentUser!.copyWith(
                      name: nameController.text,
                      bio: bioController.text,
                    ),
                    context: context,
                    bannerPic: bannerPicFile,
                    profilePic: profilePicFile,
                  );
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Pallete.limeColor,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: isLoading || currentUser == null
          ? const Loader()
          : Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: bannerPicFile != null
                              ? Image.file(
                                  bannerPicFile!,
                                  fit: BoxFit.fitWidth,
                                )
                              : currentUser.bannerPic.isEmpty
                                  ? Container(
                                      color: Pallete.limeColor,
                                    )
                                  : Image.network(
                                      currentUser.bannerPic,
                                      fit: BoxFit.fitWidth,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: GestureDetector(
                          onTap: selectProfileImage,
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Pallete.backgroundColor,
                            child: profilePicFile != null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(profilePicFile!),
                                    radius: 40,
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(currentUser.profilePic),
                                    radius: 40,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    hintText: 'Bio',
                    contentPadding: EdgeInsets.all(20),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
    );
  }
}
