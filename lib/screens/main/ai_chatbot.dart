import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:healjai_project/service/aiChat.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  ChatMessage({required this.text, required this.isMe});
}

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: "สวัสดีค้าบวันนี้มีเรื่องอะไรไม่สบายใจรึป่าว? หรืออยากจะพูดคุยเล่นก็ได้นะ :)", isMe: false),
  ];
  bool _isTyping = false;

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async{
    String userText = _messageController.text;
    if (userText.trim().isEmpty) return;

    FocusScope.of(context).unfocus();


    // ระบบส่งแชท
    setState(() {
      _messages.add(ChatMessage(text: userText, isMe: true));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();
    final result = await SendChatToAi(userText);
    final aiText = result['reply'] as String;

    // ระบบรับแชทจาก AI
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(text: aiText, isMe: false));
        });
        _scrollToBottom();
      }
  }


  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('น้องฮีลใจ', 
        style: GoogleFonts.kanit(fontSize: 26, fontWeight: FontWeight.bold,color: Colors.black54)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Background
          Container(
            width: double.infinity, height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3E5FC), Colors.white], 
                begin: Alignment.topCenter, 
                end: Alignment.bottomCenter
              )
            ),
            child: Opacity(
              opacity: 0.5, 
              child: Image.asset('assets/images/app_bg.png', fit: BoxFit.cover)
            ),
          ),

          // 2. Logo กับ วงแหวน Pulse สีขาว
          Align(
            alignment: const Alignment(0, -0.45),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isTyping) ...[
                  // วงนอกสุด สีขาวฟุ้ง
                  Pulse(
                    infinite: true,
                    duration: const Duration(seconds: 2),
                    child: Container(
                      width: 290, height: 290,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                  // วงกลาง ขอบขาวบางๆ
                  Pulse(
                    infinite: true,
                    duration: const Duration(milliseconds: 1500),
                    child: Container(
                      width: 265, height: 265,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                      ),
                    ),
                  ),
                ],
                // ตัวโลโก้หลัก
                _buildMainLogo(),
              ],
            ),
          ),

          // 3. Chat Area
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8EE),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 55, height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDE1F9), 
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return msg.isMe ? _bubbleRight(msg.text) : _bubbleLeft(msg.text);
                        },
                      ),
                    ),
                    if (_isTyping) 
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 10),
                        child: _bubbleLeft("กำลังพิมพ์..."),
                      ),
                    _buildInputBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainLogo() {
    return Container(
      width: 230, height: 230,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(_isTyping ? 0.8 : 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
      ),
      child: const CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: AssetImage('assets/icons/app_icon.png'),
      ),
    );
  }

  Widget _bubbleLeft(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(children: [
        const CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/icons/app_icon.png')),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFE9F1D7), borderRadius: BorderRadius.circular(15)),
            child: Text(text, style: GoogleFonts.kanit(fontSize: 16)),
          ),
        ),
      ]),
    );
  }

  Widget _bubbleRight(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFF82B96D), borderRadius: BorderRadius.circular(15)),
            child: Text(text, style: GoogleFonts.kanit(fontSize: 16, color: Colors.white)),
          ),
        ),
      ]),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
      child: TextField(
        controller: _messageController,
        decoration: InputDecoration(
          hintText: 'พิมพ์ข้อความที่นี่...',
          filled: true, fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFF78B465)), 
            onPressed: _handleSend
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide(color: Colors.grey.shade100)
          ),
        ),
        onSubmitted: (_) => _handleSend(),
      ),
    );
  }
}