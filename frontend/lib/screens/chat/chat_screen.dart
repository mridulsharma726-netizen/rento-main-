import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/socket_service.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? productId;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.productId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _pollingTimer;
  // Stored so we can pass the exact same reference to off(), preventing
  // accidental removal of other screens' listeners on the same event.
  Function(dynamic)? _messageHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversation(widget.otherUserId);
      _startListening();
    });
  }

  void _startListening() {
    final socket = SocketService();
    if (socket.isConnected) {
      // Build the handler once and keep a reference so dispose() can remove
      // exactly this function without touching other screens' handlers.
      _messageHandler = (data) {
        if (!mounted) return;
        final msg = MessageModel.fromJson(Map<String, dynamic>.from(data as Map));
        // Only add messages that belong to this conversation.
        if (msg.senderId == widget.otherUserId || msg.receiverId == widget.otherUserId) {
          context.read<ChatProvider>().addMessage(msg);
          _scrollToBottom();
        }
      };
      socket.on('new_message', _messageHandler!);
    } else {
      // Fallback: poll every 5s when socket unavailable (web without WS, etc.)
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) context.read<ChatProvider>().loadConversation(widget.otherUserId);
      });
    }
  }

  @override
  void dispose() {
    // Remove only this screen's handler — leaves other open chats untouched.
    if (_messageHandler != null) {
      SocketService().off('new_message', _messageHandler);
      _messageHandler = null;
    }
    _pollingTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty) return;

    _msgCtrl.clear();
    final success = await context.read<ChatProvider>().sendMessage(
      receiverId: widget.otherUserId,
      productId: widget.productId,
      message: msg,
    );

    if (success) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myId = context.read<AuthProvider>().userModel?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.otherUserName),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = provider.messages[i];
                    final isMe = msg.senderId == myId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.accent : AppColors.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Text(
                          msg.message,
                          style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 15),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
