import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';

/// Custom painter for soccer field lines overlay on the game pitch.
class SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryWhite.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.15, paint);

    final topPenaltyBox = Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.6, size.height * 0.25);
    canvas.drawRect(topPenaltyBox, paint);

    final bottomPenaltyBox = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.75,
      size.width * 0.6,
      size.height * 0.25,
    );
    canvas.drawRect(bottomPenaltyBox, paint);

    final topGoalArea = Rect.fromLTWH(size.width * 0.3, 0, size.width * 0.4, size.height * 0.12);
    canvas.drawRect(topGoalArea, paint);

    final bottomGoalArea = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.88,
      size.width * 0.4,
      size.height * 0.12,
    );
    canvas.drawRect(bottomGoalArea, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
