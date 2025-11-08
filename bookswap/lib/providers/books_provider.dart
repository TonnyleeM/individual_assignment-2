import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class BooksProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<BookModel> _allBooks = [];
  List<BookModel> _myBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookModel> get allBooks => _allBooks;
  List<BookModel> get myBooks => _myBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BooksProvider() {
    _loadBooks();
    _loadMyBooks();
  }

  // Load all available books
  void _loadBooks() {
    _firestoreService.getBooks().listen((books) {
      _allBooks = books;
      notifyListeners();
    });
  }

  // Load user's books
  void _loadMyBooks() {
    final user = _auth.currentUser;
    if (user != null) {
      _firestoreService.getBooksByOwner(user.uid).listen((books) {
        _myBooks = books;
        notifyListeners();
      });
    }
  }

  // Create book
  Future<bool> createBook({
    required String title,
    required String author,
    String? swapFor, // ← ADD THIS LINE
    required String condition,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }

      // Create book model (temporary ID, will be replaced)
      final book = BookModel(
        id: '', // Will be set by Firestore
        title: title,
        author: author,
        condition: condition,
        coverImageUrl: null,
        ownerId: user.uid,
        ownerName: user.displayName ?? user.email ?? 'Unknown',
        status: 'available',
        createdAt: DateTime.now(),
      );

      // Save to Firestore first to get document ID
      final bookId = await _firestoreService.createBook(book);

      // Upload image if provided (using the real bookId)
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadBookCover(imageFile, bookId);
        // Update book with image URL
        final updatedBook = book.copyWith(id: bookId, coverImageUrl: imageUrl);
        await _firestoreService.updateBook(updatedBook);
      } else {
        // Update book with real ID even if no image
        final updatedBook = book.copyWith(id: bookId);
        await _firestoreService.updateBook(updatedBook);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update book
  Future<bool> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String condition,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }

      String? imageUrl = existingImageUrl;

      // Upload new image if provided
      if (imageFile != null) {
        // Delete old image if exists
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await _storageService.deleteBookCover(existingImageUrl);
        }
        // Upload new image
        imageUrl = await _storageService.uploadBookCover(imageFile, bookId);
      }

      // Get existing book
      final existingBook = await _firestoreService.getBookById(bookId);
      if (existingBook == null) {
        throw 'Book not found';
      }

      // Update book model
      final updatedBook = existingBook.copyWith(
        title: title,
        author: author,
        condition: condition,
        coverImageUrl: imageUrl,
      );

      // Update in Firestore
      await _firestoreService.updateBook(updatedBook);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete book
  Future<bool> deleteBook(String bookId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get book to delete image
      final book = await _firestoreService.getBookById(bookId);
      if (book?.coverImageUrl != null && book!.coverImageUrl!.isNotEmpty) {
        await _storageService.deleteBookCover(book.coverImageUrl!);
      }

      // Delete from Firestore
      await _firestoreService.deleteBook(bookId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
