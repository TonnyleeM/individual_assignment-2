import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload book cover image
  Future<String> uploadBookCover(File imageFile, String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final ref = _storage
          .ref()
          .child('book_covers')
          .child(user.uid)
          .child('$bookId.jpg');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Error uploading image: ${e.toString()}';
    }
  }

  // Delete book cover image
  Future<void> deleteBookCover(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      // Ignore errors when deleting (image might not exist)
      print('Error deleting image: $e');
    }
  }
}
