import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:uuid/uuid.dart';

final storageAPIProvider = Provider((ref) {
  return StorageAPI();
});

class StorageAPI {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor();

  Future<List<String>> uploadImages(List<File> files) async {
    final List<String> uploadedImageUrls = [];
    const uuid = Uuid();

    for (final file in files) {
      final String fileName = uuid.v1();
      final Reference storageRef = _storage
          .ref()
          .child('${FirebaseConstants.filesFolder}/$fileName.jpg');
      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = await downloadUrl.ref.getDownloadURL();
      uploadedImageUrls.add(url);
    }

    return uploadedImageUrls;
  }
}
