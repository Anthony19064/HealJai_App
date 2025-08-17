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
    String? token = await getJWTToken();

    _socket = IO.io(apiURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.disconnect();
    _socket.auth = {'token': token};
    _socket.connect();

    _socket.on('unauthorized', (data) {
      print('⛔️ Unauthorized: $data');
    });

    _socket.on('matched', (roomId) {
      final role = chatProvider.role;

      //clearค่าเก่า
      chatProvider.clearRoomId(notify: false);
      chatProvider.clearListMessage(notify: false);

      chatProvider.setRoomId(roomId); // บันทึก roomId
      if (router.canPop()) {
        router.pop(); // ปิด dialog
      }
      Future.microtask(() {
        router.push('/chat/room/$role'); // ไปหน้าแชทตาม Role
      });
    });

    _socket.on('receiveMessage', (data) {
      final message = data['message'];
      final Sender = data['sender'];
      final time = data['time'];
      chatProvider.addMessage(message, Sender, time);
    });

    _socket.on('chatDisconnected', (_) {
      chatProvider.clearRoomId();
      chatProvider.clearListMessage();
      chatProvider.clearRole();
      router.go('/chat');
    });

    _socket.onConnectError((data) {
      print('❌ Connect Error: $data');
    });

    _socket.onDisconnect((_) {
      print('⚠️ Socket disconnected');
    });

    _isInitialized = true; // ป้องกันการ register event handler ซ้ำ
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

  //ส่งข้อความ
  void sendMessage(String roomId, String message, String time, String role) {
    _socket.emit('sendMessage', {
      'roomId': roomId,
      'message': message,
      'time': time,
      'role': role,
    });
  }

  //จับคู่แชท
  void matchChat(String role) {
    _socket.emit('register', role);
  }

  //ยกเลิกจับคู่
  void cancelMatch() {
    _socket.emit('cancelRegister');
  }

  //จบบทสนทนา
  void endChat() {
    _socket.emit('endChat');
  }

  bool get isConnected => _socket.connected; // ✅ เช็คว่าเชื่อมแล้วไหม

  // รอจนกว่าจะเชื่อมต่อ socket
  Future<void> waitUntilConnected() async {
    if (_socket.connected) return;
    final completer = Completer<void>();

    // กันการเรียกซ้ำหลายรอบ
    _socket.once('connect', (_) => completer.complete());

    return completer.future;
  }
}
