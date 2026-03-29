import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:healjai_project/providers/chatProvider.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/dashboard.dart';
import 'package:provider/provider.dart';

class EndChatScreen extends StatefulWidget {
  const EndChatScreen({super.key});

  @override
  State<EndChatScreen> createState() => _EndChatScreenState();
}

class _EndChatScreenState extends State<EndChatScreen> {
  bool _showReportForm = false;
  final _reasonController = TextEditingController();
  String? _selectedReason;
  bool _isSubmitting = false;

  static const List<String> _presetReasons = [
    'พฤติกรรมไม่เหมาะสม',
    'คำพูดรุนแรง / ก้าวร้าว',
    'เนื้อหาลามกอนาจาร',
    'สแปม / โฆษณา',
    'อื่นๆ',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1A28),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder:
              (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
          child:
              _showReportForm
                  ? _buildReportForm(key: const ValueKey('report'))
                  : _buildMainOptions(key: const ValueKey('main')),
        ),
      ),
    );
  }

  // ─── หน้าหลัก ─────────────────────────────────────────────────────────────
  Widget _buildMainOptions({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: Color(0xFF7FD8EB),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'การสนทนาจบแล้ว',
            style: GoogleFonts.mali(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ขอบคุณที่ใช้เวลาพูดคุยกันนะ 🌙',
            style: GoogleFonts.mali(fontSize: 16, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 56),

          // ── ปุ่มจับคู่ใหม่ ──
          _buildButton(
            label: 'จับคู่ใหม่',
            icon: Icons.refresh_rounded,
            bgColor: const Color(0xFF7FD8EB),
            textColor: Colors.white,
            onTap: () {
              context.go('/chat');
            },
          ),
          const SizedBox(height: 14),

          // ── ปุ่มรายงาน ──
          _buildButton(
            label: 'รายงานคู่สนทนา',
            icon: Icons.flag_rounded,
            bgColor: Colors.transparent,
            textColor: const Color(0xFFFD7D7E),
            borderColor: const Color(0xFFFD7D7E),
            onTap: () => setState(() => _showReportForm = true),
          ),
          const SizedBox(height: 14),

          // ── ปุ่มกลับหน้าหลัก ──
          TextButton(
            onPressed: () => context.go('/'),
            child: Text(
              'กลับหน้าหลัก',
              style: GoogleFonts.mali(
                fontSize: 15,
                color: Colors.white38,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── หน้าฟอร์มรายงาน ──────────────────────────────────────────────────────
  Widget _buildReportForm({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => setState(() => _showReportForm = false),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'ย้อนกลับ',
                  style: GoogleFonts.mali(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Header
          Text(
            '🚨 รายงานคู่สนทนา',
            style: GoogleFonts.mali(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'เราจะตรวจสอบและดำเนินการโดยเร็วนะ',
            style: GoogleFonts.mali(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 28),

          // Label
          Text(
            'เลือกเหตุผล *',
            style: GoogleFonts.mali(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),

          // Preset reason chips
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children:
                _presetReasons.map((reason) {
                  final isSelected = _selectedReason == reason;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedReason = reason),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFFD7D7E)
                                : Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFFFD7D7E)
                                  : Colors.white24,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        reason,
                        style: GoogleFonts.mali(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 28),

          // Textfield รายละเอียด
          Text(
            'รายละเอียดเพิ่มเติม',
            style: GoogleFonts.mali(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            maxLength: 200,
            style: GoogleFonts.mali(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'อธิบายเพิ่มเติมได้เลยนะ (ถ้ามี)',
              hintStyle: GoogleFonts.mali(color: Colors.white30, fontSize: 14),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              counterStyle: GoogleFonts.mali(color: Colors.white30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFD7D7E),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),

          // ปุ่ม Submit
          GestureDetector(
            onTap:
                (_selectedReason == null || _isSubmitting)
                    ? null
                    : _submitReport,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color:
                    _selectedReason == null
                        ? Colors.white12
                        : const Color(0xFFFD7D7E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        )
                        : Text(
                          'ส่งรายงาน',
                          style: GoogleFonts.mali(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color:
                                _selectedReason == null
                                    ? Colors.white30
                                    : Colors.white,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border:
              borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.mali(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    late final Chatprovider chatProvider;
    chatProvider = Provider.of<Chatprovider>(context, listen: false);

    final roomId = chatProvider.roomId4log;
    String userId = await getUserId();

    // TODO: ส่ง fullReason ไป backend / socket ของคุณ
    await Future.delayed(const Duration(seconds: 1)); // จำลอง API call

    setState(() => _isSubmitting = false);
    // await ReportChat(userId_sender, userId_reciver, _selectedReason! , "Chat", _reasonController.text);
    await ReportChat(userId, roomId, _selectedReason, 'Chat', _reasonController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ส่งรายงานเรียบร้อยแล้วนะ 👍',
            style: GoogleFonts.mali(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      context.go('/chat');
    }
  }
}
