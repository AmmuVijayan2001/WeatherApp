import 'package:flutter/material.dart';

class AbstractPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grey = Paint()..color = const Color(0xFFE6E6EA);
    final orange = Paint()..color = const Color(0xFFF36C6C);
    final blue = Paint()..color = const Color(0xFF2D2B55);
    final yellow = Paint()..color = const Color(0xFFF3B562);

    final greyCenter = Offset(size.width * 1.05, size.height * -0.02);
    final greyRadius = size.width * 0.6;
    canvas.drawCircle(greyCenter, greyRadius, grey);

    final greyDripY = greyCenter.dy + greyRadius * 0.75;
    _drip(canvas, size.width * 0.86, greyDripY, size.height * 0.26, grey);
    _drip(canvas, size.width * 0.90, greyDripY + 10, size.height * 0.22, grey);
    _drip(canvas, size.width * 0.94, greyDripY + 5, size.height * 0.18, grey);

    final orangeCenter = Offset(size.width * 0.22, size.height * 0.05);
    final orangeRadius = size.width * 0.42;
    canvas.drawCircle(orangeCenter, orangeRadius, orange);

    final orangeDripY = orangeCenter.dy + orangeRadius * 0.65;
    _drip(canvas, size.width * 0.16, orangeDripY, size.height * 0.24, orange);
    _drip(
      canvas,
      size.width * 0.22,
      orangeDripY + 10,
      size.height * 0.28,
      orange,
    );

    final blueCenter = Offset(size.width * 0.58, size.height * -0.02);
    final blueRadius = size.width * 0.45;
    canvas.drawCircle(blueCenter, blueRadius, blue);

    final blueDripY = blueCenter.dy + blueRadius * 0.75;
    _drip(canvas, size.width * 0.52, blueDripY, size.height * 0.30, blue);
    _drip(canvas, size.width * 0.58, blueDripY + 8, size.height * 0.34, blue);
    _drip(canvas, size.width * 0.64, blueDripY - 5, size.height * 0.26, blue);

    final yellowCenter = Offset(size.width * 0.28, size.height * -0.18);
    final yellowRadius = size.width * 0.28;
    canvas.drawCircle(yellowCenter, yellowRadius, yellow);

    final yellowDripY = yellowCenter.dy + yellowRadius * 0.85;
    _drip(canvas, size.width * 0.26, yellowDripY, size.height * 0.16, yellow);
    _drip(
      canvas,
      size.width * 0.30,
      yellowDripY + 6,
      size.height * 0.14,
      yellow,
    );
  }

  void _drip(Canvas canvas, double x, double y, double height, Paint paint) {
    canvas.drawRect(Rect.fromLTWH(x, y, 5, height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
