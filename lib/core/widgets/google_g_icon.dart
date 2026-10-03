import 'dart:math';
import 'package:flutter/material.dart';

/// Pixel-perfect Google "G" logo — stroke-based, vector, crisp at any size.
class GoogleGIcon extends StatelessWidget {
  final double size;
  const GoogleGIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/google_g_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _GoogleGPainter()),
        );
      },
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _red    = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green  = Color(0xFF34A853);
  static const _blue   = Color(0xFF4285F4);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final double outerR = w * 0.46;
    final double innerR = w * 0.26;
    final double sw     = outerR - innerR;
    final double arcR   = (outerR + innerR) / 2;
    final Rect arcRect  = Rect.fromCircle(center: Offset(cx, cy), radius: arcR);
    final double deg    = pi / 180.0;

    Paint p(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // ── Four arc segments ──────────────────────────────────────
    // Red  : top-right down to bottom-left (253° → 53°, 160° sweep)
    canvas.drawArc(arcRect, 253 * deg, (360 - 253 + 53) * deg, false, p(_red));
    // Yellow: bottom-left  (188° → 253°)
    canvas.drawArc(arcRect, 188 * deg, 65 * deg, false, p(_yellow));
    // Green : bottom-right (127° → 188°)
    canvas.drawArc(arcRect, 127 * deg, 61 * deg, false, p(_green));
    // Blue  : right arc    (53°  → 90°)
    canvas.drawArc(arcRect, 53 * deg, 37 * deg, false, p(_blue));

    // ── Blue crossbar (horizontal bar of the G) ────────────────
    final double barTop = cy - sw * 0.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx, barTop, cx + outerR + 1, barTop + sw),
        Radius.circular(sw * 0.2),
      ),
      Paint()
        ..color = _blue
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

