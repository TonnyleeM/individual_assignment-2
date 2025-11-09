import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart' show MessageModel;
import '../services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ChatModel> _chats = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ChatProvider() {
    _loadChats();
  }

  // Load user's chats
  void _loadChats() {
    final user = _auth.currentUser;
    if (user != null) {
      _firestoreService.getUserChats(user.uid).listen((chats) {
        _chats = chats;
        notifyListeners();
      });
    }
  }

  // Load messages for a specific chat
  void loadMessages(String chatId) {
    _firestoreService.getChatMessages(chatId).listen((messages) {
      _currentMessages = messages;
      notifyListeners();
    });
  }

  // Send a message
  Future<bool> sendMessage(String chatId, String text) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }

      if (text.trim().isEmpty) {
        throw 'Message cannot be empty';
      }

      await _firestoreService.sendMessage(
        chatId,
        user.uid,
        user.displayName ?? user.email ?? 'Unknown',
        text.trim(),
      );

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

  // Get or create chat with another user
  Future<String> getOrCreateChat(String otherUserId, String otherUserName, {String? bookId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }

      return await _firestoreService.getOrCreateChat(
        user.uid,
        user.displayName ?? user.email ?? 'Unknown',
        otherUserId,
        otherUserName,
        bookId: bookId,
      );
    } catch (e) {
      throw 'Error creating chat: ${e.toString()}';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _currentMessages = [];
    notifyListeners();
  }
}

