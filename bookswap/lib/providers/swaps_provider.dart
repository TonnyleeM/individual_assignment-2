import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/swap_model.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';

class SwapsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SwapModel> _myOffers = []; // Swaps I initiated
  List<SwapModel> _receivedOffers = []; // Swaps I received
  bool _isLoading = false;
  String? _errorMessage;

  List<SwapModel> get myOffers => _myOffers;
  List<SwapModel> get receivedOffers => _receivedOffers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SwapsProvider() {
    _loadSwaps();
  }

  // Load swaps
  void _loadSwaps() {
    final user = _auth.currentUser;
    if (user != null) {
      // Load swaps where user is sender
      _firestoreService.getSwapsBySender(user.uid).listen((swaps) {
        _myOffers = swaps;
        notifyListeners();
      });

      // Load swaps where user is receiver
      _firestoreService.getSwapsByReceiver(user.uid).listen((swaps) {
        _receivedOffers = swaps;
        notifyListeners();
      });
    }
  }

  // Create swap offer
  Future<bool> createSwapOffer(BookModel book) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }

      // Check if user is trying to swap their own book
      if (book.ownerId == user.uid) {
        throw 'You cannot swap your own book';
      }

      // Check if book is already pending
      if (book.status != 'available') {
        throw 'This book is no longer available for swap';
      }

      // Create swap model
      final swap = SwapModel(
        id: '', // Will be set by Firestore
        bookId: book.id,
        bookTitle: book.title,
        senderId: user.uid,
        senderName: user.displayName ?? user.email ?? 'Unknown',
        receiverId: book.ownerId,
        receiverName: book.ownerName,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // Create swap offer (this also updates book status to pending)
      await _firestoreService.createSwapOffer(swap);

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

  // Accept swap offer
  Future<bool> acceptSwap(String swapId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final swap = await _firestoreService.getSwapById(swapId);
      if (swap == null) {
        throw 'Swap not found';
      }

      // Update swap status to accepted
      await _firestoreService.updateSwapStatus(swapId, 'accepted');

      // Update book status to swapped
      await _firestoreService.updateBookStatus(swap.bookId, 'swapped');

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

  // Reject swap offer
  Future<bool> rejectSwap(String swapId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final swap = await _firestoreService.getSwapById(swapId);
      if (swap == null) {
        throw 'Swap not found';
      }

      // Update swap status to rejected
      await _firestoreService.updateSwapStatus(swapId, 'rejected');

      // Update book status back to available
      await _firestoreService.updateBookStatus(swap.bookId, 'available');

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

  // Cancel swap offer (sender cancels)
  Future<bool> cancelSwap(String swapId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final swap = await _firestoreService.getSwapById(swapId);
      if (swap == null) {
        throw 'Swap not found';
      }

      // Update swap status to rejected (cancelled)
      await _firestoreService.updateSwapStatus(swapId, 'rejected');

      // Update book status back to available
      await _firestoreService.updateBookStatus(swap.bookId, 'available');

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
