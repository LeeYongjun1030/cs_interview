import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A 6-axis radar (hexagonal) chart using CustomPainter.
class RadarChartWidget extends StatelessWidget {
  final Map<String, int> scores; // e.g. {'summary': 80, 'principle': 70, ...}
  final List<String> labels;
  final double size;

  const RadarChartWidget({
    super.key,
    required this.scores,
    required this.labels,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          scores: scores,
          labels: labels,
          axisCount: labels.length,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, int> scores;
  final List<String> labels;
  final int axisCount;

  _RadarChartPainter({
    required this.scores,
    required this.labels,
    required this.axisCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30; // Leave space for labels
    final angleStep = (2 * pi) / axisCount;

    // Draw grid lines (concentric hexagons at 20%, 40%, 60%, 80%, 100%)
    _drawGrid(canvas, center, radius, angleStep);

    // Draw axes
    _drawAxes(canvas, center, radius, angleStep);

    // Draw data polygon
    _drawDataPolygon(canvas, center, radius, angleStep);

    // Draw labels
    _drawLabels(canvas, center, radius, angleStep, size);
  }

  void _drawGrid(
      Canvas canvas, Offset center, double radius, double angleStep) {
    final gridPaint = Paint()
      ..color = AppColors.textDisabled.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 5; level++) {
      final r = radius * level / 5;
      final path = Path();

      for (int i = 0; i <= axisCount; i++) {
        final angle = -pi / 2 + i * angleStep;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }
  }

  void _drawAxes(
      Canvas canvas, Offset center, double radius, double angleStep) {
    final axisPaint = Paint()
      ..color = AppColors.textDisabled.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < axisCount; i++) {
      final angle = -pi / 2 + i * angleStep;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }
  }

  void _drawDataPolygon(
      Canvas canvas, Offset center, double radius, double angleStep) {
    final keys = scores.keys.toList();
    if (keys.isEmpty) return;

    final path = Path();
    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final points = <Offset>[];

    for (int i = 0; i < axisCount; i++) {
      final key = i < keys.length ? keys[i] : keys[0];
      final value = (scores[key] ?? 50).clamp(0, 100) / 100.0;
      final angle = -pi / 2 + i * angleStep;
      final r = radius * value;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Draw dots at each vertex
    for (final pt in points) {
      canvas.drawCircle(pt, 4, dotPaint);
      canvas.drawCircle(
          pt,
          4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius,
      double angleStep, Size size) {
    for (int i = 0; i < axisCount; i++) {
      if (i >= labels.length) break;
      final angle = -pi / 2 + i * angleStep;
      final labelRadius = radius + 18;
      var x = center.dx + labelRadius * cos(angle);
      var y = center.dy + labelRadius * sin(angle);

      final textSpan = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Center the text around the point
      x -= textPainter.width / 2;
      y -= textPainter.height / 2;

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores || oldDelegate.labels != labels;
  }
}
