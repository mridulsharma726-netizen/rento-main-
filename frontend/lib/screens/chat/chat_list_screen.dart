import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChatList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
      ),
      body: Consumer<ChatProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading && provider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (provider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text('No conversations yet', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadChatList,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: provider.conversations.length,
              separatorBuilder: (_, __) => const Divider(indent: 80, height: 1, color: AppColors.border),
              itemBuilder: (ctx, i) {
                final conv = provider.conversations[i];
                final otherUser = conv.otherUser;
                final lastMsg = conv.lastMessage;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.surface,
                    backgroundImage: (otherUser['profile_image'] != null && otherUser['profile_image'].isNotEmpty)
                        ? NetworkImage(otherUser['profile_image'])
                        : null,
                    child: (otherUser['profile_image'] == null || otherUser['profile_image'].isEmpty)
                        ? const Icon(Icons.person, color: AppColors.textDisabled)
                        : null,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(otherUser['name'] ?? 'User', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        RentoDateUtils.timeAgo(RentoDateUtils.parse(lastMsg.createdAt) ?? DateTime.now()),
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: conv.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: conv.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (conv.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/chat-detail', arguments: {
                      'userId': otherUser['id'],
                      'userName': otherUser['name'],
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
