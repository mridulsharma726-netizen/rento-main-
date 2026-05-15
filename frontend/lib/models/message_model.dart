class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? productId;
  final String message;
  final bool isRead;
  final String createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.productId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      receiverId: json['receiver_id'] as String? ?? '',
      productId: json['product_id'] as String?,
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'product_id': productId,
    'message': message,
    'is_read': isRead,
    'created_at': createdAt,
  };
}

class ConversationModel {
  final Map<String, dynamic> otherUser;
  final MessageModel lastMessage;
  final int unreadCount;

  const ConversationModel({
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      otherUser: json['other_user'] as Map<String, dynamic>? ?? {},
      lastMessage: MessageModel.fromJson(json['last_message'] as Map<String, dynamic>? ?? {}),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}
