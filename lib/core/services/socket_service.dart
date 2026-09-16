import 'package:flutter/foundation.dart';
import 'package:rsc_rider/core/config/app_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// Singleton Socket.IO connection to the realtime namespace. Connects after
// login, disconnects after logout, and resubscribes to all active rooms on
// every (re)connect so a dropped network never silently stops updates.
class SocketService {
  SocketService(AppConfig appConfig) : _baseUrl = appConfig.baseUrl;

  final String _baseUrl;
  io.Socket? _socket;
  bool _isConnected = false;
  final Set<String> _activeRooms = {};
  // Handlers registered via on() — kept here so they survive the socket
  // instance being rebuilt (connect after a full disconnect()). Attaching
  // only to the live _socket would silently drop them on recreation.
  final Map<String, List<void Function(dynamic)>> _eventHandlers = {};

  bool get isConnected => _isConnected;

  // Notified on every connect/disconnect/reconnect so the UI can show a
  // live/reconnecting indicator without polling `isConnected`.
  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);

  void connect() {
    // An existing socket keeps auto-reconnecting on its own — building a
    // second one (forceNew) would orphan it along with all its listeners.
    // Only disconnect() releases the instance and allows a fresh connect.
    if (_socket != null) return;

    // Socket.IO namespaces are part of the connection URL, not a separate
    // OptionBuilder option — e.g. https://host + /realtime.
    // Reconnection is unlimited: riders sit on flaky mobile networks, so
    // giving up after N attempts would leave a permanently dead socket.
    final options = io.OptionBuilder()
        .setTransports(['websocket'])
        .enableReconnection()
        .setReconnectionDelay(2000)
        .setReconnectionDelayMax(30000)
        .enableForceNew()
        .build()
      // Rider auth is cookie-based — carry the session cookie on the
      // socket handshake the same way DioClient does for REST calls.
      ..['withCredentials'] = true;

    _socket = io.io('$_baseUrl/realtime', options);

    // Re-attach any handlers registered before this (re)connect.
    _eventHandlers.forEach((event, handlers) {
      for (final handler in handlers) {
        _socket!.on(event, handler);
      }
    });

    _socket!.onConnect((_) {
      _isConnected = true;
      connectionStatus.value = true;
      debugPrint('[DineOut NG Rider Socket] Connected ✅');
      _resubscribeActiveRooms();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      connectionStatus.value = false;
      debugPrint('[DineOut NG Rider Socket] Disconnected');
    });

    _socket!.onConnectError((err) {
      debugPrint('[DineOut NG Rider Socket] Connect error: $err');
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      connectionStatus.value = true;
      debugPrint('[DineOut NG Rider Socket] Reconnected ✅');
      _resubscribeActiveRooms();
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    connectionStatus.value = false;
    _activeRooms.clear();
    _eventHandlers.clear();
    debugPrint('[DineOut NG Rider Socket] Disconnected 🔌');
  }

  void subscribeToRoom(String room) {
    _activeRooms.add(room);
    if (!_isConnected) connect();
    _socket?.emit('room:subscribe', {'room': room});
    debugPrint('[DineOut NG Rider Socket] Subscribed to: $room');
  }

  void unsubscribeFromRoom(String room) {
    _activeRooms.remove(room);
    _socket?.emit('room:unsubscribe', {'room': room});
    debugPrint('[DineOut NG Rider Socket] Unsubscribed: $room');
  }

  void _resubscribeActiveRooms() {
    for (final room in _activeRooms) {
      _socket?.emit('room:subscribe', {'room': room});
    }
    debugPrint(
      '[DineOut NG Rider Socket] Resubscribed to ${_activeRooms.length} rooms',
    );
  }

  void on(String event, void Function(dynamic) handler) {
    _eventHandlers.putIfAbsent(event, () => []).add(handler);
    _socket?.on(event, handler);
    debugPrint('[DineOut NG Rider Socket] Listening to: $event');
  }

  // Pass the same handler given to on() to remove only that listener —
  // omitting it clears every listener registered for the event, which would
  // also silence other unrelated subscribers (e.g. SocketEventHandler).
  void off(String event, [void Function(dynamic)? handler]) {
    if (handler != null) {
      _eventHandlers[event]?.remove(handler);
    } else {
      _eventHandlers.remove(event);
    }
    _socket?.off(event, handler);
  }
}
