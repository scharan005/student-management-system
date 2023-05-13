import 'dart:io';

import 'package:image_picker/image_picker.dart';

//Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

const String USER_COLLECTION = "Users";

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CloudStorageService() {}



  Future<String?> saveUserImageToStorage(String _uid) async {
    try {
      // Initialize the image picker
      final ImagePicker _picker = ImagePicker();

      // Pick the image
      final XFile? _imageFile = await _picker.pickImage(source: ImageSource.gallery);

      // Check if an image file was picked
      if (_imageFile != null) {
        Reference _ref = _storage.ref().child('images/users/$_uid/profile.${_imageFile.name.split('.').last}');
        UploadTask _task = _ref.putFile(File(_imageFile.path));

        // Get the download URL and return it
        return await _task.then((_result) => _result.ref.getDownloadURL());
      } else {
        print('No image file picked');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }




  Future<String?> saveChatImageToStorage(
      String _chatID, String _userID, PlatformFile _file) async {
    try {
      Reference _ref = _storage.ref().child(
          'images/chats/$_chatID/${_userID}_${Timestamp.now().millisecondsSinceEpoch}.${_file.extension}');
      UploadTask _task = _ref.putFile(
        File(_file.path.toString()),
      );
      return await _task.then(
        (_result) => _result.ref.getDownloadURL(),
      );
    } catch (e) {
      print(e);
    }
  }
}
