import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// โมเดลสำหรับข้อความแชท
class ChatMessage {
  final String text;
  final String sender; // 'user' or 'partner'
  final String time;

  ChatMessage({required this.text, required this.sender, required this.time});
}

class ChatRoomScreen extends StatefulWidget {
  final String role;
  ChatRoomScreen({super.key, required this.role});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late Color _dynamicColor;
  late String _dynamicInfoText;
  final TextEditingController MessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages =
      [
        ChatMessage(text: 'สวัสดี', sender: 'partner', time: '22:21 น.'),
        ChatMessage(text: 'สวัสดีครับ', sender: 'user', time: '22:21 น.'),
        ChatMessage(text: 'เป็นไงบ้าง', sender: 'partner', time: '22:22 น.'),
        ChatMessage(text: 'ก็พอได้อยู่ครับ', sender: 'user', time: '22:22 น.'),
      ].reversed.toList();

  @override
  void initState() {
    super.initState();
    _dynamicColor =
        widget.role == 'moon' ? Color(0xFF7FD8EB) : Color(0xFFFFA500);
    _dynamicInfoText =
        widget.role == 'moon'
            ? 'โปรดใช้คำสุภาพกับคู่สนทนาของคุณนะ :)'
            : 'โปรดรับฟังคู่สนทนาโดยไม่ตัดสินนะ :)';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF7EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.role == 'moon' ? 'พระจันทร์' : 'พระอาทิตย์',
          style: GoogleFonts.mali(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _dynamicColor, // <<--- ใช้สี dynamic
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _dynamicColor, // <<--- ใช้สี dynamic
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                _dynamicInfoText, // <<--- ใช้ข้อความ dynamic
                textAlign: TextAlign.center,
                style: GoogleFonts.mali(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                reverse: true, // ทำให้ chat เริ่มจากข้างล่าง
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 0.0,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.sender == 'user';
                  return _buildChatBubble(context, message, isUser);
                },
              ),
            ),

            MessageInput(
              inputController: MessageController,
              dynamicColor: _dynamicColor,
              onButtonPressed: () async {
                String timeNow = DateFormat('HH:mm').format(DateTime.now());

                if (MessageController.text.trim().isNotEmpty) {
                  setState(() {
                    _messages.insert(
                      0,
                      ChatMessage(
                        text: MessageController.text,
                        sender: "user",
                        time: '$timeNow น.',
                      ),
                    );
                    MessageController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(
    BuildContext context,
    ChatMessage message,
    bool isUser,
  ) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isUser
                            ? _dynamicColor
                            : Colors.white, // <<--- ใช้สี dynamic
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.mali(
                      fontSize: 16,
                      color: isUser ? Colors.white : Color(0xFF6C6C6C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 4.0,
                right: isUser ? 0 : 50,
                left: isUser ? 0 : 50,
              ),
              child: Text(
                message.time,
                style: GoogleFonts.mali(
                  fontSize: 12,
                  color: Color(0xFF939393),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final Color dynamicColor;
  final VoidCallback onButtonPressed;
  final TextEditingController inputController;

  const MessageInput({
    required this.dynamicColor,
    required this.onButtonPressed,
    required this.inputController,
    super.key,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
      child: TextFormField(
        controller: widget.inputController,
        decoration: InputDecoration(
          hintText: 'พิมพ์ข้อความที่นี่ . . . .',
          hintStyle: GoogleFonts.mali(
            color: Color(0xFFC3C3C3),
            fontWeight: FontWeight.w600,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: widget.dynamicColor, width: 2),
          ),
          fillColor: Colors.white, // สีพื้นหลัง
          filled: true,
          suffixIcon: IconButton(
            icon: Icon(Icons.send, color: widget.dynamicColor),
            onPressed: widget.onButtonPressed,
            iconSize: 24,
          ),
        ),
        style: GoogleFonts.mali(fontSize: 16),
      ),
    );
  }
}
