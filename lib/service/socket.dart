import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
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

  void initSocket(BuildContext context) {
    if (_isInitialized) {
      print('Socket already initialized');
      return;
    }

    final chatProvider = context.read<Chatprovider>();
    final router = GoRouter.of(context);

    _socket = IO.io(apiURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.on('connect', (_) {
      print('✅ Socket connected');
    });

    _socket.on('matched', (roomId) {
      final role = chatProvider.role;
      chatProvider.setRoomId(roomId); // บันทึก roomId
      if (router.canPop()) {
        router.pop(); // ปิด dialog
      }
      Future.microtask(() {
        router.go('/chat/room/$role'); // ไปหน้าแชทตาม Role
      });
    });

    _socket.on('receiveMessage', (data) {
      print('ได้รับข้อความ');
      final message = data['message'];
      final Sender = data['sender'];
      final time = data['time'];
      chatProvider.addMessage(message, Sender, time);
    });

    _socket.on('chatDisconnected', (_) {
      print('จบบทสนทนาจากอีกฝั่ง');
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
    print('กำลังจับคู่');
    _socket.emit('register', role);
  }

  //ยกเลิกจับคู่
  void cancelMatch() {
    print('ยกเลิกจับคู่แล้ว');
    _socket.emit('cancleRegister');
  }

  //จบบทสนทนา
  void endChat() {
    _socket.emit('endChat');
  }

  //ตัดการเชื่อมต่อกับ socket.io
  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
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
