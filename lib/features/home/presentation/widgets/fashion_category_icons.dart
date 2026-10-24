import 'package:flutter/material.dart';

/// Bespoke vector fashion icons for the Shop By Category section.
/// Provides pixel-perfect, scalable silhouettes for Jackets, Trousers, Dresses, and Shorts.

class FashionCategoryIcon extends StatelessWidget {
  final int categoryIndex; // 0: Jackets, 1: Trousers, 2: Dresses, 3: Shorts
  final Color color;
  final double size;

  const FashionCategoryIcon({
    super.key,
    required this.categoryIndex,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    CustomPainter painter;
    switch (categoryIndex) {
      case 0:
        painter = JacketIconPainter(color: color);
        break;
      case 1:
        painter = TrouserIconPainter(color: color);
        break;
      case 2:
        painter = DressIconPainter(color: color);
        break;
      case 3:
      default:
        painter = ShortsIconPainter(color: color);
        break;
    }

    return CustomPaint(
      size: Size(size, size),
      painter: painter,
    );
  }
}

/// 1. Blazer / Jacket Icon Painter
class JacketIconPainter extends CustomPainter {
  final Color color;
  const JacketIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Outer blazer body with sleeves and lapels
    final bodyPath = Path()
      ..moveTo(8.5, 3.5)
      ..lineTo(4.8, 5.5) // Left shoulder
      ..lineTo(2.2, 13.5) // Left sleeve outer
      ..lineTo(5.2, 14.5) // Left sleeve cuff
      ..lineTo(6.8, 10.2) // Left armpit
      ..lineTo(6.5, 20.5) // Left waist down to hem
      ..lineTo(17.5, 20.5) // Bottom hem
      ..lineTo(17.2, 10.2) // Right armpit
      ..lineTo(18.8, 14.5) // Right sleeve cuff
      ..lineTo(21.8, 13.5) // Right sleeve outer
      ..lineTo(19.2, 5.5) // Right shoulder
      ..lineTo(15.5, 3.5) // Right collar
      ..close();

    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, strokePaint);

    // Lapel & V-neck opening
    final lapelPath = Path()
      ..moveTo(8.5, 3.5)
      ..lineTo(12.0, 11.0)
      ..lineTo(15.5, 3.5);
    canvas.drawPath(lapelPath, strokePaint);

    // Center button line
    canvas.drawLine(const Offset(12.0, 11.0), const Offset(12.0, 20.5), strokePaint);

    // Buttons
    final buttonPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12.0, 13.8), 1.1, buttonPaint);
    canvas.drawCircle(const Offset(12.0, 17.2), 1.1, buttonPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant JacketIconPainter oldDelegate) => oldDelegate.color != color;
}

/// 2. Tailored Trousers / Pants Icon Painter
class TrouserIconPainter extends CustomPainter {
  final Color color;
  const TrouserIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Pants silhouette: Waistband, outer legs, cuffs, crotch
    final pantsPath = Path()
      ..moveTo(5.5, 4.0) // Top left waist
      ..lineTo(18.5, 4.0) // Top right waist
      ..lineTo(17.5, 21.0) // Right outer leg
      ..lineTo(13.2, 21.0) // Right inner cuff
      ..lineTo(12.0, 11.0) // Inseam crotch
      ..lineTo(10.8, 21.0) // Left inner cuff
      ..lineTo(6.5, 21.0) // Left outer leg
      ..close();

    canvas.drawPath(pantsPath, fillPaint);
    canvas.drawPath(pantsPath, strokePaint);

    // Waistband seam
    canvas.drawLine(const Offset(5.7, 7.2), const Offset(18.3, 7.2), strokePaint);

    // Fly seam
    canvas.drawLine(const Offset(12.0, 7.2), const Offset(12.0, 10.5), strokePaint);

    // Front pockets accents
    final pocketPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(7.2, 7.8), const Offset(8.8, 10.5), pocketPaint);
    canvas.drawLine(const Offset(16.8, 7.8), const Offset(15.2, 10.5), pocketPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TrouserIconPainter oldDelegate) => oldDelegate.color != color;
}

/// 3. Elegant Dress / Gown Icon Painter
class DressIconPainter extends CustomPainter {
  final Color color;
  const DressIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // A-line dress silhouette with scoop neck, fitted waist, and flared skirt
    final dressPath = Path()
      ..moveTo(8.5, 3.5) // Left strap
      ..lineTo(9.5, 5.8)
      ..quadraticBezierTo(12.0, 7.2, 14.5, 5.8) // Scoop neck
      ..lineTo(15.5, 3.5) // Right strap
      ..lineTo(17.0, 5.8) // Right armhole
      ..lineTo(14.5, 11.2) // Right waist
      ..lineTo(20.5, 21.0) // Flared bottom right
      ..quadraticBezierTo(12.0, 22.5, 3.5, 21.0) // Curved bottom hem
      ..lineTo(9.5, 11.2) // Left waist
      ..lineTo(7.0, 5.8) // Left armhole
      ..close();

    canvas.drawPath(dressPath, fillPaint);
    canvas.drawPath(dressPath, strokePaint);

    // Waist belt accent
    final beltPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(9.5, 11.2), const Offset(14.5, 11.2), beltPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DressIconPainter oldDelegate) => oldDelegate.color != color;
}

/// 4. Shorts / Bermudas Icon Painter
class ShortsIconPainter extends CustomPainter {
  final Color color;
  const ShortsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Shorts silhouette: short legs ending around y=16
    final shortsPath = Path()
      ..moveTo(4.5, 5.0) // Top left waist
      ..lineTo(19.5, 5.0) // Top right waist
      ..lineTo(19.0, 16.5) // Right outer leg
      ..lineTo(13.6, 16.5) // Right leg cuff
      ..lineTo(12.0, 11.0) // Crotch curve
      ..lineTo(10.4, 16.5) // Left leg cuff
      ..lineTo(5.0, 16.5) // Left outer leg
      ..close();

    canvas.drawPath(shortsPath, fillPaint);
    canvas.drawPath(shortsPath, strokePaint);

    // Waistband
    canvas.drawLine(const Offset(4.8, 8.0), const Offset(19.2, 8.0), strokePaint);

    // Fly seam
    canvas.drawLine(const Offset(12.0, 8.0), const Offset(12.0, 11.0), strokePaint);

    // Slanted pockets accents
    final accentPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(6.4, 8.8), const Offset(8.0, 11.8), accentPaint);
    canvas.drawLine(const Offset(17.6, 8.8), const Offset(16.0, 11.8), accentPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ShortsIconPainter oldDelegate) => oldDelegate.color != color;
}
