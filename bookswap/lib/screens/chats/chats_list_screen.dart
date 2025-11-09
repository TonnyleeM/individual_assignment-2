import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../utils/constants.dart';
import '../../models/message_model.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final userId = authProvider.user?.id;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(
              child: Text(
                'Please sign in to view chats',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No chats yet',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start a conversation from a swap offer!',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: chatProvider.chats.length,
                  itemBuilder: (context, index) {
                    final chat = chatProvider.chats[index];
                    final otherUserName = chat.getOtherUserName(userId);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accent,
                        child: Text(
                          otherUserName.isNotEmpty
                              ? otherUserName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text(
                        otherUserName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        chat.lastMessage,
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatTime(chat.lastMessageTime),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chat: chat,
                              otherUserName: otherUserName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
