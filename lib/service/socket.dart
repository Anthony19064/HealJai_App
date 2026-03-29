import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:healjai_project/service/token.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import '../providers/chatProvider.dart';

String apiURL = dotenv.env['BE_API_URL'] ?? '';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket _socket;
  bool _isInitialized = false;

  void initSocket(BuildContext context) async {
    if (_isInitialized) {
      return;
    }

    final chatProvider = context.read<Chatprovider>();
    final router = GoRouter.of(context);
    String? token = await getJWTAcessToken();

    _socket = IO.io(apiURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.disconnect();
    _socket.auth = {'token': token};
    _socket.connect();

    _socket.on('unauthorized', (data) async {
      if (data == "Token expired") {
        final status = await refreshToken();
        if (status == "ResetSuccess") {
          print('reset token แล้วค้าบบ');
          String? newToken = await getJWTAcessToken();
          _socket.disconnect();
          _socket.io.options?['auth'] = {'token': newToken};
          _isInitialized = false;
          initSocket(context);
        } else if (status == "Token expired") {
          router.go('/login');
        }
      }
    });

    _socket.on('matched', (roomId) {
      final role = chatProvider.role;

      chatProvider.clearRoomId(notify: false);
      chatProvider.clearListMessage(notify: false);

      chatProvider.setRoomId(roomId);
      if (router.canPop()) {
        router.pop();
      }
      Future.microtask(() {
        router.push('/chat/room/$role');
      });
    });

    _socket.on('receiveMessage', (data) {
      final message = data['message'];
      final Sender = data['sender'];
      final time = data['time'];
      chatProvider.addMessage(message, Sender, time);
    });

    // ✅ แก้ตรงนี้จุดเดียว: ไปหน้า /chat/end แทน /chat
    _socket.on('chatDisconnected', (_) {
      chatProvider.clearRoomId();
      chatProvider.clearListMessage();
      chatProvider.clearRole();
      router.push('/chat/end'); // ทั้งสองฝั่งจะถูก push มาหน้านี้
    });

    _socket.onConnectError((data) {
      print('❌ Connect Error: $data');
    });

    _socket.onDisconnect((_) {
      print('⚠️ Socket disconnected');
    });

    _isInitialized = true;
  }

  void dispose() {
    if (_isInitialized) {
      _socket.off('connect');
      _socket.off('matched');
      _socket.off('receiveMessage');
      _socket.off('chatDisconnected');
      _socket.disconnect();
      _isInitialized = false;
      print('🧹 Socket disposed');
    }
  }

  void sendMessage(String roomId, String message, String time, String role) {
    _socket.emit('sendMessage', {
      'roomId': roomId,
      'message': message,
      'time': time,
      'role': role,
    });
  }

  Future<void> matchChat(String role) async {
    await waitUntilConnected();
    if (_socket.connected) {
      _socket.emit('register', role);
    } else {
      print("❌ Socket ยังไม่ connect");
    }
  }

  void cancelMatch() {
    _socket.emit('cancelRegister');
  }

  void endChat() {
    _socket.emit('endChat');
  }

  void resetInitialization() {
    _isInitialized = false;
  }

  bool get isConnected => _socket.connected;

  Future<void> waitUntilConnected() async {
    if (_socket.connected) return;
    final completer = Completer<void>();
    _socket.once('connect', (_) => completer.complete());
    return completer.future;
  }
}
