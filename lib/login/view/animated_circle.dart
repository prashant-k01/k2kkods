import 'package:flutter/material.dart';
import 'package:k2k/utils/theme.dart';

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20)) + (50 * (animationValue - 0.5));
      final y = (size.height * 0.3) + (30 * (animationValue - 0.5)) + (i * 10);
      final radius = 2 + (animationValue * 3);
      
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}