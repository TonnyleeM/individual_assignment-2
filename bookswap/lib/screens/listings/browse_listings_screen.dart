import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/swaps_provider.dart';
import '../../widgets/book_card.dart';
import '../../utils/constants.dart';
import 'post_book_screen.dart';

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, _) {
          if (booksProvider.isLoading && booksProvider.allBooks.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            );
          }

          if (booksProvider.allBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No books available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to post a book!',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh is handled by stream
            },
            child: ListView.builder(
              itemCount: booksProvider.allBooks.length,
              itemBuilder: (context, index) {
                final book = booksProvider.allBooks[index];
                return BookCard(
                  book: book,
                  onTap: () {
                    _showSwapDialog(context, book);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostBookScreen()),
          );
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showSwapDialog(BuildContext context, book) {
    final swapsProvider = Provider.of<SwapsProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initiate Swap'),
        content: Text('Do you want to request a swap for "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await swapsProvider.createSwapOffer(book);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Swap offer sent! Check "My Offers" for updates.'
                          : swapsProvider.errorMessage ?? 'Failed to create swap offer',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text('Swap', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
