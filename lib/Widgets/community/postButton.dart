import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kIconColor = Color(0xFF757575);

class InteractionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final Color borderColor;
  final Color backgroundColor;
  const InteractionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.borderColor,
    required this.backgroundColor,
    this.iconColor,
  });
  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? kIconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.mali(
                color: kIconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
