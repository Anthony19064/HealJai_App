import 'package:flutter/material.dart';

// โมเดลสำหรับข้อความแชท
class ChatMessage {
  final String text;
  final String sender; // 'user' or 'partner'
  final String time;

  ChatMessage({required this.text, required this.sender, required this.time});
}

class Chatprovider extends ChangeNotifier {
  String? roomId;
  String? role;
  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  void setRoomId(String id) {
    roomId = id;
    notifyListeners();
  }

  void setRole(String roleUser) {
    role = roleUser;
    notifyListeners();
  }

  void addMessage(String message,String Sender, String time) {
    print('addMessage called: $message at $time');
    _messages.add(ChatMessage(text: message, sender: Sender, time: '$time น.'));
    notifyListeners();
  }

  void clearRoomId({bool notify = true}) {
    roomId = null;
    if (notify) notifyListeners();
    // print(roomId);
  }

  void clearRole({bool notify = true}) {
    role = null;
    if (notify) notifyListeners();
    // print(roomId);
  }

  void clearListMessage({bool notify = true}){
    _messages = [];
    if (notify) notifyListeners();
    // print(_messages);
  }
}
