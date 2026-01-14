import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget weatherInfoTile({
  required String imagePath,
  required String label,
  required String value,
  required int delay,
}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 600),
    curve: Curves.easeOut,
    builder: (context, animation, child) {
      return Opacity(
        opacity: animation,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: child,
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Image(image: AssetImage(imagePath), height: 30, width: 30),
          SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.padauk(
              fontSize: 15,
              color: const Color.fromARGB(255, 122, 122, 122),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF2D2B55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
