import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketClient {
  SocketClient(this._storage);

  final LocalStorage _storage;

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _disposed = false;

  bool get isConnected => _isConnected;

  Stream<Map<String, dynamic>> get messageStream {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    return _controller!.stream;
  }

  Future<void> connect() async {
    if (_isConnected || _disposed) return;

    final token = await _storage.getAccessToken();
    if (token == null) return;

    final socketUrl = dotenv.env['SOCKET_URL'] ?? '';
    if (socketUrl.isEmpty) return;

    final uri = Uri.parse('$socketUrl?token=$token');

    try {
      _controller ??= StreamController<Map<String, dynamic>>.broadcast();
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _isConnected = true;

      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      debugPrint('[SocketClient] Connected to $socketUrl');
    } catch (e) {
      debugPrint('[SocketClient] Connection failed: $e');
      _scheduleReconnect();
    }
  }

  // Sends the rider's current position during an active delivery.
  void sendLocationUpdate({
    required String deliveryId,
    required double latitude,
    required double longitude,
    required double bearing,
  }) {
    if (!_isConnected) return;
    _send({
      'type': 'location_update',
      'delivery_id': deliveryId,
      'latitude': latitude,
      'longitude': longitude,
      'bearing': bearing,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendAvailabilityUpdate({required bool isOnline}) {
    if (!_isConnected) return;
    _send({
      'type': 'availability_update',
      'is_online': isOnline,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _controller?.close();
    _controller = null;
  }

  void _send(Map<String, dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (e) {
      debugPrint('[SocketClient] Send failed: $e');
    }
  }

  void _onData(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      _controller?.add(data);
    } catch (e) {
      debugPrint('[SocketClient] Parse error: $e');
    }
  }

  void _onError(Object error) {
    debugPrint('[SocketClient] Error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('[SocketClient] Connection closed');
    _isConnected = false;
    if (!_disposed) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), connect);
  }
}
