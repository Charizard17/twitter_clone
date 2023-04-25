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

  Future<String> uploadImage(File file) async {
    final fileName = const Uuid().v1();
    final ref = _storage.ref('${FirebaseConstants.filesFolder}/$fileName.jpg');
    final url = await ref.putFile(file).then((_) => ref.getDownloadURL());
    return url;
  }

  Future<List<String>> uploadImages(List<File> files) async {
    return Future.wait(files.map((file) async {
      final fileName = const Uuid().v1();
      final downloadUrl = await _storage
          .ref()
          .child('${FirebaseConstants.filesFolder}/$fileName.jpg')
          .putFile(file)
          .then((task) => task.ref.getDownloadURL());
      return downloadUrl;
    }));
  }
}
