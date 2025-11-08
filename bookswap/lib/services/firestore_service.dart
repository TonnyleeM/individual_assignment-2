import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/swap_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all available books
  Stream<List<BookModel>> getBooks() {
    return _firestore
        .collection('books')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  // Get books by owner
  Stream<List<BookModel>> getBooksByOwner(String ownerId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  // Get single book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        return BookModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error fetching book: ${e.toString()}';
    }
  }

  // Create book
  Future<String> createBook(BookModel book) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final docRef = await _firestore.collection('books').add(book.toFirestore());
      // Update the document with the correct ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw 'Error creating book: ${e.toString()}';
    }
  }

  // Update book
  Future<void> updateBook(BookModel book) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // Verify ownership
      final existingBook = await getBookById(book.id);
      if (existingBook == null) {
        throw 'Book not found';
      }
      if (existingBook.ownerId != user.uid) {
        throw 'You do not have permission to edit this book';
      }

      await _firestore
          .collection('books')
          .doc(book.id)
          .update(book.toFirestore());
    } catch (e) {
      throw 'Error updating book: ${e.toString()}';
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // Verify ownership
      final book = await getBookById(bookId);
      if (book == null) {
        throw 'Book not found';
      }
      if (book.ownerId != user.uid) {
        throw 'You do not have permission to delete this book';
      }

      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw 'Error deleting book: ${e.toString()}';
    }
  }

  // Update book status (for swap functionality)
  Future<void> updateBookStatus(String bookId, String status) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'status': status,
      });
    } catch (e) {
      throw 'Error updating book status: ${e.toString()}';
    }
  }

  // Swap Methods
  // Create swap offer
  Future<String> createSwapOffer(SwapModel swap) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // Update book status to pending
      await updateBookStatus(swap.bookId, 'pending');

      // Create swap document
      final docRef = await _firestore.collection('swaps').add(swap.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Error creating swap offer: ${e.toString()}';
    }
  }

  // Get swaps where user is sender
  Stream<List<SwapModel>> getSwapsBySender(String senderId) {
    return _firestore
        .collection('swaps')
        .where('senderId', isEqualTo: senderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromFirestore(doc))
            .toList());
  }

  // Get swaps where user is receiver
  Stream<List<SwapModel>> getSwapsByReceiver(String receiverId) {
    return _firestore
        .collection('swaps')
        .where('receiverId', isEqualTo: receiverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromFirestore(doc))
            .toList());
  }

  // Update swap status
  Future<void> updateSwapStatus(String swapId, String status) async {
    try {
      await _firestore.collection('swaps').doc(swapId).update({
        'status': status,
      });
    } catch (e) {
      throw 'Error updating swap status: ${e.toString()}';
    }
  }

  // Get swap by ID
  Future<SwapModel?> getSwapById(String swapId) async {
    try {
      final doc = await _firestore.collection('swaps').doc(swapId).get();
      if (doc.exists) {
        return SwapModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error fetching swap: ${e.toString()}';
    }
  }

  // Chat Methods
  // Generate chat ID (sorted user IDs to ensure uniqueness)
  String _generateChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // Get or create chat between two users
  Future<String> getOrCreateChat(String userId1, String userName1, String userId2, String userName2, {String? bookId}) async {
    try {
      final chatId = _generateChatId(userId1, userId2);
      final chatRef = _firestore.collection('chats').doc(chatId);

      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) {
        // Create new chat
        await chatRef.set({
          'user1Id': userId1 < userId2 ? userId1 : userId2,
          'user1Name': userId1 < userId2 ? userName1 : userName2,
          'user2Id': userId1 < userId2 ? userId2 : userId1,
          'user2Name': userId1 < userId2 ? userName2 : userName1,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          if (bookId != null) 'bookId': bookId,
        });
      }

      return chatId;
    } catch (e) {
      throw 'Error creating chat: ${e.toString()}';
    }
  }

  // Get all chats for a user
  Stream<List<ChatModel>> getUserChats(String userId) {
    // Combine both queries - get chats where user is user1 or user2
    // Note: Firestore doesn't support OR queries, so we need to combine manually
    final stream1 = _firestore
        .collection('chats')
        .where('user1Id', isEqualTo: userId)
        .snapshots();
    
    final stream2 = _firestore
        .collection('chats')
        .where('user2Id', isEqualTo: userId)
        .snapshots();

    // Combine streams using StreamController
    final controller = StreamController<List<ChatModel>>();
    final Map<String, ChatModel> allChats = {};

    void updateList() {
      final list = allChats.values.toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      if (!controller.isClosed) {
        controller.add(list);
      }
    }

    StreamSubscription? sub1;
    StreamSubscription? sub2;

    sub1 = stream1.listen((snapshot) {
      for (var doc in snapshot.docs) {
        allChats[doc.id] = ChatModel.fromFirestore(doc);
      }
      updateList();
    });

    sub2 = stream2.listen((snapshot) {
      for (var doc in snapshot.docs) {
        allChats[doc.id] = ChatModel.fromFirestore(doc);
      }
      updateList();
    });

    controller.onCancel = () {
      sub1?.cancel();
      sub2?.cancel();
    };

    return controller.stream;
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  // Send a message
  Future<void> sendMessage(String chatId, String senderId, String senderName, String text) async {
    try {
      final messagesRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages');

      // Add message
      await messagesRef.add({
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update chat's last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error sending message: ${e.toString()}';
    }
  }
}
