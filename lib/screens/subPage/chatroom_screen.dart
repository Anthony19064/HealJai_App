import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/providers/chatProvider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../service/socket.dart';
import '../../Widgets/chatroompage/custom_dialogpopup.dart';

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
  late final Chatprovider chatProvider;

  final socket = SocketService();

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<Chatprovider>(context, listen: false);
    _dynamicColor =
        widget.role == 'talker' ? Color(0xFF7FD8EB) : Color(0xFFFFA500);
    _dynamicInfoText =
        widget.role == 'talker'
            ? 'โปรดใช้คำสุภาพกับคู่สนทนาของคุณนะ :)'
            : 'โปรดรับฟังคู่สนทนาโดยไม่ตัดสินนะ :)';
  }

  @override
  void dispose() {
    super.dispose();
    socket.endChat();
    chatProvider.clearRoomId(notify: false);
    chatProvider.clearRole(notify: false);
    chatProvider.clearListMessage(notify: false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitConfirmationDialog();
        // ไม่ต้องทำอะไรอัตโนมัติ
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFFFF7EB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: _showExitConfirmationDialog,
          ),
          title: Text(
            widget.role == 'talker' ? 'พระจันทร์' : 'พระอาทิตย์',
            style: GoogleFonts.mali(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _dynamicColor,
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
                  color: _dynamicColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  _dynamicInfoText,
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
                child: Consumer<Chatprovider>(
                  builder: (context, chatProvider, child) {
                    final _messages = chatProvider.messages.reversed.toList();
                    return ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 0.0,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final obj_message = _messages[index];
                        final isUser = obj_message.sender == 'user';
                        return _buildChatBubble(context, obj_message, isUser);
                      },
                    );
                  },
                ),
              ),
              MessageInput(
                inputController: MessageController,
                dynamicColor: _dynamicColor,
                onButtonPressed: () async {
                  String time = DateFormat('HH:mm').format(DateTime.now());
                  final messageUser = MessageController.text;
                  final role = widget.role;
                  final roomId = chatProvider.roomId;

                  if (MessageController.text.trim().isNotEmpty) {
                    socket.sendMessage(roomId!, messageUser, time, role);
                    chatProvider.addMessage(messageUser, "user", time);
                    MessageController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExitConfirmationDialog() async {
    // กำหนดค่ารูปภาพและสีตาม Role ของผู้ใช้
    final String role =
        widget.role == 'talker'
            ? 'moonLeave'
            : 'sunLeave'; //ถ้าpathรูปผิดจะโชว์เป็นiconแทน
    final Color primaryColor = _dynamicColor;

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // อนุญาตให้กดข้างนอกเพื่อปิดได้
      builder: (BuildContext dialogContext) {
        return CustomExitDialog(
          animationRole: role,
          primaryColor: primaryColor,
          onCancel: () {
            Navigator.of(dialogContext).pop(); // ปิด Dialog
          },
          onConfirm: () {
            // ทำ Action เดิม
            socket.endChat();
            chatProvider.clearRole();
            chatProvider.clearRoomId();
            chatProvider.clearListMessage();

            // ปิด Dialog ก่อน แล้วค่อยเปลี่ยนหน้า
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            if (context.mounted) context.pop();
          },
        );
      },
    );
  }

  // ข้อความ
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
                    color: isUser ? _dynamicColor : Colors.white,
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

//ช่องกรอกข้อความ
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
          fillColor: Colors.white,
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
