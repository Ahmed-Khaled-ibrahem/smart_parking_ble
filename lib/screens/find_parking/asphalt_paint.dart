import 'dart:math' as math;
import 'package:flutter/material.dart' hide NavigationMode;
import '../../model/slot.dart';

class ParkingAsphalt2Painter extends CustomPainter {
  final List<ParkingSlot> slots;
  final String? selectedSlotId;
  final double pathProgress;
  final double carProgress;
  final NavigationMode navMode;
  final Size canvasSize;

  ParkingAsphalt2Painter({
    required this.slots,
    required this.selectedSlotId,
    required this.pathProgress,
    required this.carProgress,
    required this.navMode,
    required this.canvasSize,
  });

  // Layout Ratios (Must match ParkingScreen)
  static const gridWRatio = 0.96;
  static const gridHRatio = 0.88; // Matches screen
  static const slotWRatio = 0.16;
  static const internalLaneRatio = 0.11;
  static const mainVerticalRoadRatio = 0.14;
  static const slotHRatio = 0.10;
  static const mainHorizontalRoadRatio = 0.20;

  Rect _slotRect(int globalCol, int globalRow) {
    final w = canvasSize.width;
    final h = canvasSize.height;
    final gridW = w * gridWRatio;
    final gridH = h * gridHRatio;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    final slotW = gridW * slotWRatio;
    final internalLaneW = gridW * internalLaneRatio;
    final mainVRoadW = gridW * mainVerticalRoadRatio;
    final slotH = gridH * 0.08; // Matches screen
    final horizontalGap = gridH * 0.20; // Matches screen

    double x = startX;
    if (globalCol == 0) {
      x = startX;
    } else if (globalCol == 1) {
      x = startX + slotW + internalLaneW;
    } else if (globalCol == 2) {
      x = startX + 2 * slotW + internalLaneW + mainVRoadW;
    } else {
      x = startX + 3 * slotW + 2 * internalLaneW + mainVRoadW;
    }

    double y = topPad;
    if (globalRow < 5) {
      y = topPad + globalRow * slotH;
    } else {
      y = topPad + globalRow * slotH + horizontalGap;
    }

    const verticalGap = 6.0;
    return Rect.fromLTWH(x, y + verticalGap / 2, slotW, slotH - verticalGap);
  }

  Offset _slotCenter(int col, int row) {
    return _slotRect(col, row).center;
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
    final asphaltColor = const Color(0xFF454545);
    final paint = Paint()..color = asphaltColor;

    final w = size.width;
    final h = size.height;
    final gridW = w * gridWRatio;
    final gridH = h * gridHRatio;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    final slotW = gridW * slotWRatio;
    final internalLaneW = gridW * internalLaneRatio;
    final mainVRoadW = gridW * mainVerticalRoadRatio;
    final horizontalGap = gridH * 0.20; // Matches screen
    final slotH = gridH * 0.08; // Matches screen

    // Main Vertical Road
    final mvX = startX + 2 * slotW + internalLaneW;
    canvas.drawRect(Rect.fromLTWH(mvX, 0, mainVRoadW, h), paint);

    // Main Horizontal Road
    final mhY = topPad + 5 * slotH;
    canvas.drawRect(Rect.fromLTWH(0, mhY, w, horizontalGap), paint);

    // Internal Vertical Lanes
    final ivLX = startX + slotW;
    canvas.drawRect(Rect.fromLTWH(ivLX, topPad, internalLaneW, gridH), paint);

    final ivRX = startX + 3 * slotW + internalLaneW + mainVRoadW;
    canvas.drawRect(Rect.fromLTWH(ivRX, topPad, internalLaneW, gridH), paint);
  }

  void _drawRoadLanes(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final gridW = w * gridWRatio;
    final gridH = h * gridHRatio;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    final slotW = gridW * slotWRatio;
    final internalLaneW = gridW * internalLaneRatio;
    final mainVRoadW = gridW * mainVerticalRoadRatio;
    final horizontalGap = gridH * 0.20; // Matches screen
    final slotH = gridH * 0.08; // Matches screen

    // Main Vertical Road Dashes
    final mvCX = startX + 2 * slotW + internalLaneW + mainVRoadW / 2;
    _drawDashedVertLine(canvas, dashPaint, mvCX, 10, h - 10);

    // Main Horizontal Road Dashes
    final mhCY = topPad + 5 * slotH + horizontalGap / 2;
    _drawDashedHorizLine(canvas, dashPaint, 10, w - 10, mhCY);

    // Internal Lanes (thin lines)
    final ivLCX = startX + slotW + internalLaneW / 2;
    _drawDashedVertLine(canvas, dashPaint, ivLCX, topPad, topPad + gridH);

    final ivRCX =
        startX + 3 * slotW + internalLaneW + mainVRoadW + internalLaneW / 2;
    _drawDashedVertLine(canvas, dashPaint, ivRCX, topPad, topPad + gridH);
  }

  void _drawDashedVertLine(
      Canvas canvas,
      Paint paint,
      double x,
      double top,
      double bottom,
      ) {
    const dashLen = 10.0;
    const gapLen = 10.0;
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

  void _drawDashedHorizLine(
      Canvas canvas,
      Paint paint,
      double left,
      double right,
      double y,
      ) {
    const dashLen = 10.0;
    const gapLen = 10.0;
    double x = left;
    while (x < right) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dashLen, right), y),
        paint,
      );
      x += dashLen + gapLen;
    }
  }

  void _drawDirectionArrows(Canvas canvas, Size size) {
    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final gridW = w * gridWRatio;
    final gridH = h * gridHRatio;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    final slotW = gridW * slotWRatio;
    final internalLaneW = gridW * internalLaneRatio;
    final mainVRoadW = gridW * mainVerticalRoadRatio;
    final horizontalGap = gridH * 0.20; // Matches screen
    final slotH = gridH * 0.08; // Matches screen

    // Vertical Main Arrows
    final mvCX = startX + 2 * slotW + internalLaneW + mainVRoadW / 2;
    _drawArrowDown(canvas, arrowPaint, mvCX, topPad + gridH * 0.15);
    _drawArrowDown(canvas, arrowPaint, mvCX, topPad + gridH * 0.85);

    // Horizontal Main Arrows
    final mhCY = topPad + 5 * slotH + horizontalGap / 2;
    _drawArrowRight(canvas, arrowPaint, w * 0.15, mhCY);
    _drawArrowRight(canvas, arrowPaint, w * 0.85, mhCY);
  }

  void _drawArrowDown(Canvas canvas, Paint paint, double cx, double cy) {
    const sz = 6.0;
    canvas.drawLine(Offset(cx, cy - 10), Offset(cx, cy), paint);
    canvas.drawLine(Offset(cx - sz, cy - sz), Offset(cx, cy), paint);
    canvas.drawLine(Offset(cx + sz, cy - sz), Offset(cx, cy), paint);
  }

  void _drawArrowRight(Canvas canvas, Paint paint, double cx, double cy) {
    const sz = 6.0;
    canvas.drawLine(Offset(cx - 10, cy), Offset(cx, cy), paint);
    canvas.drawLine(Offset(cx - sz, cy - sz), Offset(cx, cy), paint);
    canvas.drawLine(Offset(cx - sz, cy + sz), Offset(cx, cy), paint);
  }

  void _drawNavigationPath(Canvas canvas, Size size) {
    if (selectedSlotId == null) return;
    final slot = slots.firstWhereOrNull((s) => s.id == selectedSlotId);
    if (slot == null) return;

    final globalCol = slot.gridPosition.dx.toInt();
    final globalRow = slot.gridPosition.dy.toInt();
    final targetOffset = _slotCenter(globalCol, globalRow);

    // Entrance at top center of main vertical road
    final w = size.width;
    final h = size.height;
    final gridW = w * gridWRatio;
    final gridH = h * gridHRatio;
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;
    final slotW = gridW * slotWRatio;
    final internalLaneW = gridW * internalLaneRatio;
    final mainVRoadW = gridW * mainVerticalRoadRatio;
    final horizontalGap = gridH * 0.20; // Matches screen
    final slotH = gridH * 0.08; // Matches screen

    final mvCX = startX + 2 * slotW + internalLaneW + mainVRoadW / 2;
    final mhCY = topPad + 5 * slotH + horizontalGap / 2;

    Offset start;
    if (navMode == NavigationMode.fromEntrance) {
      start = Offset(mvCX, 20);
    } else {
      start = Offset(20, mhCY); // Current mode starts from left road
    }

    // Pathway Logic
    // 1. Move to Main Cross (Vertical Central)
    // 2. Move to Horizontal Road intersection with the target block's lane
    // 3. Move to Target Lane Y
    // 4. Move to Target Slot

    final blockLaneX = (globalCol < 2)
        ? startX + slotW + internalLaneW / 2
        : startX + 3 * slotW + internalLaneW + mainVRoadW + internalLaneW / 2;

    final List<Offset> pathPoints = [];
    pathPoints.add(start);
    pathPoints.add(Offset(mvCX, start.dy)); // Ensure on vertical road
    pathPoints.add(Offset(mvCX, mhCY)); // Go to crossroad
    pathPoints.add(Offset(blockLaneX, mhCY)); // Go to block lane intersection
    pathPoints.add(
      Offset(blockLaneX, targetOffset.dy),
    ); // Move to row level in lane
    pathPoints.add(targetOffset); // Enter slot

    // Clean path
    final List<Offset> unique = [];
    if (pathPoints.isNotEmpty) {
      unique.add(pathPoints.first);
      for (int i = 1; i < pathPoints.length; i++) {
        if ((pathPoints[i] - pathPoints[i - 1]).distance > 1) {
          unique.add(pathPoints[i]);
        }
      }
    }

    _drawGlowingPath(canvas, unique);
    _drawAnimatedDots(canvas, unique);
    _drawMovingCar(canvas, unique);
  }

  void _drawGlowingPath(Canvas canvas, List<Offset> path) {
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.15)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corePaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathObj = Path();
    if (path.isEmpty) return;
    pathObj.moveTo(path.first.dx, path.first.dy);
    for (int i = 1; i < path.length; i++) {
      pathObj.lineTo(path[i].dx, path[i].dy);
    }
    canvas.drawPath(pathObj, glowPaint);
    canvas.drawPath(pathObj, corePaint);
  }

  void _drawAnimatedDots(Canvas canvas, List<Offset> path) {
    if (path.length < 2) return;
    final totalLen = _pathLength(path);
    const spacing = 20.0;
    final offset = (pathProgress * spacing);
    double dist = offset;
    while (dist < totalLen) {
      final pos = _pointAtDistance(path, dist);
      canvas.drawCircle(pos, 2, Paint()..color = Colors.white.withOpacity(0.6));
      dist += spacing;
    }
  }

  void _drawMovingCar(Canvas canvas, List<Offset> path) {
    if (path.length < 2) return;
    final totalLen = _pathLength(path);
    final dist = carProgress * totalLen;
    final pos = _pointAtDistance(path, dist);
    final ahead = _pointAtDistance(path, math.min(dist + 5, totalLen));
    final angle = math.atan2(ahead.dy - pos.dy, ahead.dx - pos.dx);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle); // Simplified: faces direction of movement

    final carPaint = Paint()..color = Colors.white;
    final rect = Rect.fromCenter(center: Offset.zero, width: 22, height: 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      carPaint,
    );

    // Windshield
    canvas.drawRect(
      Rect.fromLTWH(4, -5, 6, 10),
      Paint()..color = Colors.blue.withOpacity(0.5),
    );

    canvas.restore();
  }

  double _pathLength(List<Offset> points) {
    double len = 0;
    for (int i = 1; i < points.length; i++) {
      len += (points[i] - points[i - 1]).distance;
    }
    return len;
  }

  Offset _pointAtDistance(List<Offset> points, double distance) {
    if (points.isEmpty) return Offset.zero;
    if (distance <= 0) return points.first;
    double remaining = distance;
    for (int i = 1; i < points.length; i++) {
      final seg = points[i] - points[i - 1];
      final l = seg.distance;
      if (l == 0) continue;
      if (remaining <= l) return points[i - 1] + (seg / l) * remaining;
      remaining -= l;
    }
    return points.last;
  }

  @override
  bool shouldRepaint(covariant ParkingAsphalt2Painter oldDelegate) {
    return oldDelegate.pathProgress != pathProgress ||
        oldDelegate.carProgress != carProgress ||
        oldDelegate.selectedSlotId != selectedSlotId ||
        oldDelegate.navMode != navMode;
  }
}
