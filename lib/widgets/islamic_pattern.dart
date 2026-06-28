import 'dart:math';
import 'package:flutter/material.dart';

class IslamicPatternDecoration extends StatelessWidget {
  final Color color;
  final double opacity;

  const IslamicPatternDecoration({
    super.key,
    this.color = const Color(0xFFD4AF37),
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    // Opacity widget'ı her frame saveLayer (offscreen buffer) tetikler;
    // SliverAppBar scroll animasyonunda jank yapar. Alpha'yı renge gömüp
    // RepaintBoundary ile izole ediyoruz.
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _IslamicPatternPainter(
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color color;

  _IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 60.0;
    final rows = (size.height / spacing).ceil() + 1;
    final cols = (size.width / spacing).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cx = col * spacing + (row.isOdd ? spacing / 2 : 0);
        final cy = row * spacing;
        _drawOctagonStar(canvas, Offset(cx, cy), spacing * 0.35, paint);
      }
    }
  }

  void _drawOctagonStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 8;
    final innerRadius = radius * 0.5;

    for (int i = 0; i < points; i++) {
      final outerAngle = (i * 2 * pi / points) - pi / 2;
      final innerAngle = ((i + 0.5) * 2 * pi / points) - pi / 2;

      final outerX = center.dx + radius * cos(outerAngle);
      final outerY = center.dy + radius * sin(outerAngle);
      final innerX = center.dx + innerRadius * cos(innerAngle);
      final innerY = center.dy + innerRadius * sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
