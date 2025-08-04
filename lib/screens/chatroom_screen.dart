import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// โมเดลสำหรับข้อความแชท
class ChatMessage {
  final String text;
  final String sender; // 'user' or 'partner'
  final String time;

  ChatMessage({required this.text, required this.sender, required this.time});
}

class ChatRoomScreen extends StatelessWidget {
  final String role;
  
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'สวัสดี', sender: 'partner', time: '22:21 น.'),
    ChatMessage(text: 'สวัสดีครับ', sender: 'user', time: '22:21 น.'),
    ChatMessage(text: 'เป็นไงบ้าง', sender: 'partner', time: '22:22 น.'),
    ChatMessage(text: 'ก็พอได้อยู่ครับ', sender: 'user', time: '22:22 น.'),
  ];

  ChatRoomScreen({
    super.key,
    required this.role,
  });

  // <<--- เพิ่ม getters เพื่อกำหนดค่า dynamic ตาม role
  Color get _dynamicColor => role == 'moon' ? const Color.fromARGB(255, 102, 227, 243) : const Color(0xFFFFA500);
  Color get _dynamicInfoBgColor => role == 'moon' ? const Color(0xFFE6F7FF) : const Color(0xFFFEE8B7);
  Color get _dynamicInfoTextColor => role == 'moon' ? const Color.fromARGB(255, 2, 146, 165): const Color(0xFFFFA500);
  String get _dynamicInfoText => role == 'moon' 
    ? 'คุณเป็นผู้เล่าเรื่อง โปรดใช้คำสุภาพกับคู่สนทนาของคุณนะ :)' 
    : 'คุณเป็นผู้รับฟัง โปรดใช้คำสุภาพกับคู่สนทนาของคุณนะ :)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          role == 'moon' ? 'พระจันทร์' : 'พระอาทิตย์',
          style: GoogleFonts.mali(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _dynamicColor, // <<--- ใช้สี dynamic
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: _dynamicInfoBgColor, // <<--- ใช้สี dynamic
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              _dynamicInfoText, // <<--- ใช้ข้อความ dynamic
              textAlign: TextAlign.center,
              style: GoogleFonts.mali(
                fontSize: 14,
                color: _dynamicInfoTextColor, // <<--- ใช้สี dynamic
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.sender == 'user';
                return _buildChatBubble(context, message, isUser);
              },
            ),
          ),
          
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, ChatMessage message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isUser)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFFC0E0FF)),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isUser ? _dynamicColor : Colors.white, // <<--- ใช้สี dynamic
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.mali(fontSize: 16, color: const Color(0xFF464646)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 4.0,
                right: isUser ? 0 : 48.0,
                left: isUser ? 48.0 : 0,
              ),
              child: Text(
                message.time,
                style: GoogleFonts.mali(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildMessageInput(BuildContext context) {
  return Padding( // ระยะห่างกล่องข้อความกับขอบจอ
    padding: const EdgeInsets.only(bottom: 30.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'พิมพ์ข้อความที่นี่ . . . .',
                hintStyle: GoogleFonts.mali(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0.0,
                ),
              ),
              style: GoogleFonts.mali(fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: () {
              print('ข้อความถูกส่ง!');
            },
            icon: Icon(Icons.send, color: _dynamicColor),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    ),
  );
}
}