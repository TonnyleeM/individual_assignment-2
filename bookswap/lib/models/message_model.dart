import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ChatModel {
  final String id;
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? bookId; // Optional: link to book being swapped

  ChatModel({
    required this.id,
    required this.user1Id,
    required this.user1Name,
    required this.user2Id,
    required this.user2Name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.bookId,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      user1Id: data['user1Id'] ?? '',
      user1Name: data['user1Name'] ?? '',
      user2Id: data['user2Id'] ?? '',
      user2Name: data['user2Name'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bookId: data['bookId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user1Id': user1Id,
      'user1Name': user1Name,
      'user2Id': user2Id,
      'user2Name': user2Name,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      if (bookId != null) 'bookId': bookId,
    };
  }

  // Get the other user's info
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  String getOtherUserName(String currentUserId) {
    return currentUserId == user1Id ? user2Name : user1Name;
  }
}

