import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadItemImageBytes(Uint8List imageBytes, String itemId) async {
    try {
      Reference ref = _storage.ref().child('item_images').child('$itemId.jpg');
      
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      
      UploadTask uploadTask = ref.putData(imageBytes, metadata);
      
      // Timeout after 15 seconds if CORS or Network blocks the upload
      TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Image upload timed out. Please check Firebase Storage CORS settings.');
        },
      );
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Firebase Storage Error: $e');
      rethrow;
    }
  }
}