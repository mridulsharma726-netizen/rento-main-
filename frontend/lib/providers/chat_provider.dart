import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChatList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.getChatList();
      if (res['success'] == true) {
        final list = res['conversations'] as List;
        _conversations = list.map((c) => ConversationModel.fromJson(c)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversation(String otherUserId) async {
    _isLoading = true;
    _error = null;
    // We don't notify here to prevent flickering if messages are already there
    
    try {
      final res = await _api.getConversation(otherUserId);
      if (res['success'] == true) {
        final list = res['messages'] as List;
        _messages = list.map((m) => MessageModel.fromJson(m)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required String receiverId,
    String? productId,
    required String message,
  }) async {
    try {
      final res = await _api.sendMessage({
        'receiver_id': receiverId,
        if (productId != null) 'product_id': productId,
        'message': message,
      });
      
      if (res['success'] == true) {
        final newMessage = MessageModel.fromJson(res['message'] as Map<String, dynamic>);
        _messages.add(newMessage);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void addMessage(MessageModel message) {
    // Avoid duplicates (socket + API polling can race)
    if (_messages.any((m) => m.id == message.id)) return;
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
