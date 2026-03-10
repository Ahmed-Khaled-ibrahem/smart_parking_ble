import 'dart:math' as math;
import 'package:flutter/material.dart' hide NavigationMode;
import '../../model/slot.dart';

class ParkingLotPainter extends CustomPainter {
  final List<ParkingSlot> slots;
  final String? selectedSlotId;
  final double pathProgress;
  final double carProgress;
  final NavigationMode navMode;
  final Size canvasSize;

  ParkingLotPainter({
    required this.slots,
    required this.selectedSlotId,
    required this.pathProgress,
    required this.carProgress,
    required this.navMode,
    required this.canvasSize,
  });

  // Helper: computes same positions as _buildSlotGrid
  Rect _slotRect(int col, int row) {
    final w = canvasSize.width;
    final h = canvasSize.height;
    final gridW = w * 0.94;
    final gridH = h * 0.65;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    const laneRatio = 0.32;
    const sideRatio = (1 - laneRatio) / 2;
    final slotW = gridW * sideRatio;
    final laneW = gridW * laneRatio;

    final rowCount = 4;
    final slotH = gridH / rowCount;
    const verticalGap = 8.0;

    final x = startX + col * (slotW + laneW);
    final y = topPad + row * slotH + verticalGap / 2;
    return Rect.fromLTWH(x, y, slotW, slotH - verticalGap);
  }

  Offset _slotCenter(int col, int row) {
    final r = _slotRect(col, row);
    return r.center;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawAsphalt(canvas, size);
    _drawRoadLanes(canvas, size);
    _drawDirectionArrows(canvas, size);
    if (selectedSlotId != null) {
      _drawNavigationPath(canvas, size);
    }
  }

  void _drawAsphalt(Canvas canvas, Size size) {
    // Slightly lighter asphalt strips for lanes
    final lanePaint = Paint()..color = const Color(0xFF515151);
    final w = size.width;
    final h = size.height;
    final gridW = w * 0.94;
    final gridH = h * 0.65;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    const laneRatio = 0.32;
    const sideRatio = (1 - laneRatio) / 2;
    final slotW = gridW * sideRatio;
    final laneW = gridW * laneRatio;

    // Central Vertical lane
    final x = startX + slotW;
    canvas.drawRect(
      Rect.fromLTWH(x, topPad - 30, laneW, gridH + 60),
      lanePaint,
    );
  }

  void _drawRoadLanes(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final gridW = w * 0.94;
    final gridH = h * 0.65;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    const laneRatio = 0.32;
    const sideRatio = (1 - laneRatio) / 2;
    final slotW = gridW * sideRatio;
    final laneW = gridW * laneRatio;

    // Center dashes in central vertical lane
    final cx = startX + slotW + laneW / 2;
    _drawDashedVertLine(
      canvas,
      dashPaint,
      cx,
      topPad - 20,
      topPad + gridH + 20,
    );
  }

  void _drawDashedVertLine(
    Canvas canvas,
    Paint paint,
    double x,
    double top,
    double bottom,
  ) {
    const dashLen = 8.0;
    const gapLen = 8.0;
    double y = top;
    while (y < bottom) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, math.min(y + dashLen, bottom)),
        paint,
      );
      y += dashLen + gapLen;
    }
  }

  void _drawDirectionArrows(Canvas canvas, Size size) {
    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final gridW = w * 0.94;
    final gridH = h * 0.65;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    const laneRatio = 0.32;
    const sideRatio = (1 - laneRatio) / 2;
    final slotW = gridW * sideRatio;
    final laneW = gridW * laneRatio;

    // Downward arrows in central vertical lane
    final cx = startX + slotW + laneW / 2;
    _drawArrowDown(canvas, arrowPaint, cx, topPad + gridH * 0.2);
    _drawArrowDown(canvas, arrowPaint, cx, topPad + gridH * 0.5);
    _drawArrowDown(canvas, arrowPaint, cx, topPad + gridH * 0.8);
  }

  void _drawArrowDown(Canvas canvas, Paint paint, double cx, double cy) {
    const half = 6.0;
    const stem = 10.0;
    canvas.drawLine(Offset(cx, cy - stem), Offset(cx, cy), paint);
    canvas.drawLine(Offset(cx - half, cy - half), Offset(cx, cy), paint);
    canvas.drawLine(Offset(cx + half, cy - half), Offset(cx, cy), paint);
  }

  void _drawNavigationPath(Canvas canvas, Size size) {
    if (selectedSlotId == null) return;
    final slot = slots.firstWhereOrNull((s) => s.id == selectedSlotId);
    if (slot == null) return;

    final col = slot.gridPosition.dx.toInt();
    final row = slot.gridPosition.dy.toInt();
    final targetCenter = _slotCenter(col, row);

    // Determine start
    final Offset start;
    if (navMode == NavigationMode.fromEntrance) {
      start = Offset(size.width / 2, size.height * 0.04);
    } else {
      // Simulate current position: left side mid-height
      start = Offset(size.width * 0.05, size.height * 0.5);
    }

    // Build waypoints
    final List<Offset> path = _buildPath(start, targetCenter, col, row, size);

    // Draw glowing path
    _drawGlowingPath(canvas, path);
    // Draw animated dotted overlay
    _drawAnimatedDots(canvas, path);
    // Draw moving car along path
    _drawMovingCar(canvas, path);
  }

  List<Offset> _buildPath(
    Offset start,
    Offset target,
    int col,
    int row,
    Size size,
  ) {
    final h = size.height;
    final w = size.width;
    final gridW = w * 0.94;
    final gridH = h * 0.65;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    const laneRatio = 0.32;
    const sideRatio = (1 - laneRatio) / 2;
    final slotW = gridW * sideRatio;
    final laneW = gridW * laneRatio;

    // Central lane X
    final laneX = startX + slotW + laneW * 0.5;

    // Target vertical position (center of target row)
    final rowCount = 4;
    final slotH = gridH / rowCount;
    final targetY = topPad + (row + 0.5) * slotH;

    final List<Offset> points = [
      start,
      Offset(laneX, start.dy),
      Offset(laneX, targetY),
      target,
    ];

    // Filter out identical consecutive points to avoid 0-length segments
    final List<Offset> uniquePoints = [];
    if (points.isNotEmpty) {
      uniquePoints.add(points.first);
      for (int i = 1; i < points.length; i++) {
        if (points[i] != points[i - 1]) {
          uniquePoints.add(points[i]);
        }
      }
    }
    return uniquePoints;
  }

  void _drawGlowingPath(Canvas canvas, List<Offset> path) {
    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.15)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final corePaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pathObj = _buildPathObj(path);
    canvas.drawPath(pathObj, glowPaint);
    canvas.drawPath(pathObj, corePaint);
  }

  Path _buildPathObj(List<Offset> points) {
    final p = Path();
    if (points.isEmpty) return p;
    p.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      p.lineTo(points[i].dx, points[i].dy);
    }
    return p;
  }

  void _drawAnimatedDots(Canvas canvas, List<Offset> path) {
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final totalLen = _pathLength(path);
    if (totalLen <= 0) return;

    const spacing = 18.0;
    final offset = pathProgress * spacing;
    double traveled = offset;

    while (traveled < totalLen) {
      final pos = _pointAtDistance(path, traveled);
      final alpha =
          0.2 + 0.6 * (1 - ((traveled - offset) / totalLen).clamp(0.0, 1.0));
      dotPaint.color = Colors.white.withOpacity(alpha.clamp(0.0, 1.0));
      canvas.drawCircle(pos, 2.5, dotPaint);
      traveled += spacing;
    }
  }

  void _drawMovingCar(Canvas canvas, List<Offset> path) {
    final totalLen = _pathLength(path);
    final dist = carProgress * totalLen;
    final pos = _pointAtDistance(path, dist);

    // Direction
    final ahead = _pointAtDistance(path, (dist + 5).clamp(0, totalLen));
    final angle = math.atan2(ahead.dy - pos.dy, ahead.dx - pos.dx);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle - math.pi / 2); // car faces upward by default

    // Glow around car
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset.zero, 12, glowPaint);

    // Draw mini car
    final carPainter = _CarPainter();
    canvas.translate(-12, -10);
    carPainter.paint(canvas, const Size(24, 16));

    canvas.restore();
  }

  double _pathLength(List<Offset> points) {
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }

  Offset _pointAtDistance(List<Offset> points, double distance) {
    if (points.isEmpty) return Offset.zero;
    if (distance <= 0) return points.first;

    double remaining = distance;
    for (int i = 1; i < points.length; i++) {
      final seg = points[i] - points[i - 1];
      final len = seg.distance;
      if (len == 0) continue;
      if (remaining <= len) {
        return points[i - 1] + (seg / len) * remaining;
      }
      remaining -= len;
    }
    return points.last;
  }

  @override
  bool shouldRepaint(covariant ParkingLotPainter oldDelegate) {
    return oldDelegate.pathProgress != pathProgress ||
        oldDelegate.carProgress != carProgress ||
        oldDelegate.selectedSlotId != selectedSlotId ||
        oldDelegate.navMode != navMode;
  }
}

class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = const Color(0xFFECECEC)
      ..style = PaintingStyle.fill;
    final windowPaint = Paint()
      ..color = const Color(0xFF80DEEA).withOpacity(0.7)
      ..style = PaintingStyle.fill;
    final wheelPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Body
    final bodyPath = Path()
      ..moveTo(w * 0.1, h * 0.6)
      ..lineTo(w * 0.15, h * 0.3)
      ..lineTo(w * 0.3, h * 0.1)
      ..lineTo(w * 0.7, h * 0.1)
      ..lineTo(w * 0.85, h * 0.3)
      ..lineTo(w * 0.9, h * 0.6)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Window
    final windowPath = Path()
      ..moveTo(w * 0.32, h * 0.28)
      ..lineTo(w * 0.38, h * 0.14)
      ..lineTo(w * 0.62, h * 0.14)
      ..lineTo(w * 0.68, h * 0.28)
      ..close();
    canvas.drawPath(windowPath, windowPaint);

    // Wheels
    canvas.drawCircle(Offset(w * 0.22, h * 0.72), h * 0.18, wheelPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.72), h * 0.18, wheelPaint);

    // Wheel shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.22, h * 0.72), h * 0.08, shinePaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.72), h * 0.08, shinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
