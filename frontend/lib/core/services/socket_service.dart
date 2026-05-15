import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;

  /// Tracks all active handlers so they can be re-registered after a
  /// reconnect, and so individual handlers can be removed without nuking
  /// every other listener on the same event.
  final Map<String, List<Function(dynamic)>> _handlers = {};

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (isConnected) return;

    // Dispose any dead socket before creating a fresh one so we never hold
    // two sockets simultaneously.
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }

    final socketUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      if (kDebugMode) debugPrint('⚡ Socket connected');
      // Re-register any handlers that were set up before this connect call
      // (covers the reconnect-after-disconnect case).
      _handlers.forEach((event, handlers) {
        for (final h in handlers) {
          _socket?.on(event, h);
        }
      });
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) debugPrint('🔌 Socket disconnected');
    });

    _socket!.onError((err) {
      if (kDebugMode) debugPrint('❌ Socket error: $err');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _handlers.clear();
  }

  void on(String event, Function(dynamic) handler) {
    _handlers[event] ??= [];
    if (!_handlers[event]!.contains(handler)) {
      _handlers[event]!.add(handler);
    }
    _socket?.on(event, handler);
  }

  /// Remove a specific [handler] for [event].  If [handler] is omitted all
  /// listeners for the event are removed (use only when intentional).
  void off(String event, [Function? handler]) {
    if (handler == null) {
      _handlers.remove(event);
      _socket?.off(event);
      return;
    }

    final list = _handlers[event];
    if (list == null) return;

    list.remove(handler);

    // socket_io_client's off() removes all handlers at once, so we clear the
    // event and re-add the remaining ones.
    _socket?.off(event);
    for (final h in list) {
      _socket?.on(event, h);
    }
  }
}
