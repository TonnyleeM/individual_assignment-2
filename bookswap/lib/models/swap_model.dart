class SwapModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String senderId;
  final String receiverId;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  SwapModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });
}


