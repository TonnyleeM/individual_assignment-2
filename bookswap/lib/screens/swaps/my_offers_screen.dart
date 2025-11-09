import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/swaps_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/constants.dart';
import '../../models/swap_model.dart';
import '../chats/chat_screen.dart';
import '../../models/message_model.dart';

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: const Text('My Offers'),
          backgroundColor: AppColors.primary,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(text: 'Sent'),
              Tab(text: 'Received'),
            ],
          ),
        ),
        body: Consumer<SwapsProvider>(
          builder: (context, swapsProvider, _) {
            if (swapsProvider.isLoading &&
                swapsProvider.myOffers.isEmpty &&
                swapsProvider.receivedOffers.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              );
            }

            return TabBarView(
              children: [
                // Sent Offers Tab
                _buildOffersList(
                  context,
                  swapsProvider.myOffers,
                  userId ?? '',
                  isSent: true,
                ),
                // Received Offers Tab
                _buildOffersList(
                  context,
                  swapsProvider.receivedOffers,
                  userId ?? '',
                  isSent: false,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOffersList(
    BuildContext context,
    List<SwapModel> offers,
    String userId, {
    required bool isSent,
  }) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSent ? Icons.send_outlined : Icons.inbox_outlined,
              size: 80,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            Text(
              isSent ? 'No swap offers sent' : 'No swap offers received',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final swap = offers[index];
        return _buildOfferCard(context, swap, isSent);
      },
    );
  }

  Widget _buildOfferCard(BuildContext context, SwapModel swap, bool isSent) {
    final swapsProvider = Provider.of<SwapsProvider>(context, listen: false);

    Color statusColor;
    IconData statusIcon;
    switch (swap.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap.bookTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSent
                            ? 'To: ${swap.receiverName}'
                            : 'From: ${swap.senderName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        swap.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Chat button (available for pending or accepted swaps)
            if (swap.status == 'pending' || swap.status == 'accepted')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final chatProvider = Provider.of<ChatProvider>(
                        context,
                        listen: false,
                      );
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final currentUserId = authProvider.user?.id ?? '';

                      final otherUserId = isSent
                          ? swap.receiverId
                          : swap.senderId;
                      final otherUserName = isSent
                          ? swap.receiverName
                          : swap.senderName;

                      try {
                        final chatId = await chatProvider.getOrCreateChat(
                          otherUserId,
                          otherUserName,
                          bookId: swap.bookId,
                        );

                        // Get the chat model
                        final chat = ChatModel(
                          id: chatId,
                          user1Id: currentUserId.compareTo(otherUserId) < 0
                              ? currentUserId
                              : otherUserId,
                          user1Name: currentUserId.compareTo(otherUserId) < 0
                              ? (authProvider.user?.displayName ??
                                    authProvider.user?.email ??
                                    'Unknown')
                              : otherUserName,
                          user2Id: currentUserId.compareTo(otherUserId) < 0
                              ? otherUserId
                              : currentUserId,
                          user2Name: currentUserId.compareTo(otherUserId) < 0
                              ? otherUserName
                              : (authProvider.user?.displayName ??
                                    authProvider.user?.email ??
                                    'Unknown'),
                          lastMessage: '',
                          lastMessageTime: DateTime.now(),
                          bookId: swap.bookId,
                        );

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chat: chat,
                                otherUserName: otherUserName,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error starting chat: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.accent,
                    ),
                    label: const Text(
                      'Chat',
                      style: TextStyle(color: AppColors.accent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              ),
            if (swap.status == 'pending') ...[
              if (isSent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cancel Swap'),
                          content: const Text(
                            'Are you sure you want to cancel this swap offer?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        final success = await swapsProvider.cancelSwap(swap.id);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Swap offer cancelled'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await swapsProvider.acceptSwap(
                            swap.id,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Swap accepted!'
                                      : swapsProvider.errorMessage ??
                                            'Failed to accept swap',
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await swapsProvider.rejectSwap(
                            swap.id,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Swap rejected'
                                      : swapsProvider.errorMessage ??
                                            'Failed to reject swap',
                                ),
                                backgroundColor: success
                                    ? Colors.orange
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
