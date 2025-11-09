import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? bookId;

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

  factory ChatModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final ts = data['lastMessageTime'];
    DateTime parsedTime;
    if (ts == null) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(0);
    } else if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else if (ts is DateTime) {
      parsedTime = ts;
    } else {
      parsedTime = DateTime.tryParse(ts.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return ChatModel(
      id: doc.id,
      user1Id: data['user1Id'] ?? '',
      user1Name: data['user1Name'] ?? '',
      user2Id: data['user2Id'] ?? '',
      user2Name: data['user2Name'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: parsedTime,
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
      'lastMessageTime': lastMessageTime, // Firestore client will accept DateTime
      if (bookId != null) 'bookId': bookId,
    };
  }

  // Helper used by ChatsListScreen to get the other participant's name
  String getOtherUserName(String? currentUserId) {
    if (currentUserId == null) return '';
    if (currentUserId == user1Id) return user2Name;
    if (currentUserId == user2Id) return user1Name;
    // If current user isn't matched, just return user2Name as a fallback
    return user2Name;
  }
}
