import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String condition; // New, Like New, Good, Used
  final String? coverImageUrl;
  final String ownerId;
  final String ownerName;
  final String status; // available, pending, swapped
  final DateTime createdAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.coverImageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.status,
    required this.createdAt,
  });

  // Convert Firestore document to BookModel
  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: data['condition'] ?? 'Used',
      coverImageUrl: data['coverImageUrl'],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      status: data['status'] ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert BookModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    final map = {
      'title': title,
      'author': author,
      'condition': condition,
      'coverImageUrl': coverImageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  // Create a copy with updated fields
  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? condition,
    String? coverImageUrl,
    String? ownerId,
    String? ownerName,
    String? status,
    DateTime? createdAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
