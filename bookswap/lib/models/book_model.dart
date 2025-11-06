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
}


