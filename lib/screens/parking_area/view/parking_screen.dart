import 'package:flutter/material.dart' hide NavigationMode;
import '../model/slot.dart';
import 'widgets/lot_painter.dart';
import 'widgets/slot_widget.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen>
    with TickerProviderStateMixin {
  late List<ParkingSlot> slots;
  String? selectedSlotId;
  NavigationMode navMode = NavigationMode.fromEntrance;

  // Animation controllers
  late AnimationController _pathAnimController;
  late AnimationController _carMoveController;
  late AnimationController _pulseController;

  // Car position along path (0.0 → 1.0)
  late Animation<double> _carProgress;

  @override
  void initState() {
    super.initState();
    _initSlots();
    _pathAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _carMoveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _carProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _carMoveController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  void _initSlots() {
    slots = [];
    final blockLabels = ['A', 'B', 'C', 'D'];
    for (int b = 0; b < 4; b++) {
      final blockX = b % 2; // 0=Left, 1=Right
      final blockY = b ~/ 2; // 0=Top, 1=Bottom
      for (int i = 0; i < 10; i++) {
        final colInBlock = i ~/ 5; // 0, 1
        final rowInBlock = i % 5; // 0, 1, 2, 3, 4

        final globalCol = blockX * 2 + colInBlock;
        final globalRow = blockY * 5 + rowInBlock;

        final id = '${blockLabels[b]}${i + 1}';
        slots.add(
          ParkingSlot(
            id: id,
            status: (i == 1 || i == 6 || (b == 1 && i == 7))
                ? ParkingStatus.occupied
                : ParkingStatus.available,
            gridPosition: Offset(globalCol.toDouble(), globalRow.toDouble()),
            type: (i == 4) ? ParkingType.disablePerson : ParkingType.normal,
          ),
        );
      }
    }
  }

  void _onSlotTap(String id) {
    setState(() {
      if (selectedSlotId == id) {
        selectedSlotId = null;
        _carMoveController.reset();
      } else {
        selectedSlotId = id;
        _carMoveController.forward(from: 0);
      }
    });
  }

  void _toggleSlotStatus(String id) {
    setState(() {
      final slot = slots.firstWhere((s) => s.id == id);
      slot.status = slot.status == ParkingStatus.available
          ? ParkingStatus.occupied
          : ParkingStatus.available;
    });
  }

  @override
  void dispose() {
    _pathAnimController.dispose();
    _carMoveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildParkingLot()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final occupied = slots
        .where((s) => s.status == ParkingStatus.occupied)
        .length;
    final available = slots.length - occupied;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Smart Parking — 4 Blocks Area',
              style: TextStyle(fontSize: 12, letterSpacing: 1.2),
            ),
          ),
          _statBadge('$available', 'FREE', const Color(0xFF00934B)),
          const SizedBox(width: 10),
          _statBadge('$occupied', 'BUSY', const Color(0xFFFF5252)),
        ],
      ),
    );
  }

  Widget _statBadge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.9), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingLot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF323232),
          borderRadius: BorderRadius.circular(15),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              children: [
                // Road + path painter
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _pathAnimController,
                    _carMoveController,
                  ]),
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(w, h),
                      painter: ParkingLotPainter(
                        slots: slots,
                        selectedSlotId: selectedSlotId,
                        pathProgress: _pathAnimController.value,
                        carProgress: _carProgress.value,
                        navMode: navMode,
                        canvasSize: Size(w, h),
                      ),
                    );
                  },
                ),
                // Slot widgets
                _buildSlotGrid(w, h),
                // Entrance / Exit labels
                _buildEntranceExit(w, h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSlotGrid(double w, double h) {
    // Layout parameters (must match LotPainter)
    final gridW = w * 0.96;
    final gridH = h * 0.88; // Reduced slightly to avoid label overlap
    final topPad = (h - gridH) / 2;
    final startX = (w - gridW) / 2;

    // Width ratios
    const slotWRatio = 0.16;
    const internalLaneRatio = 0.12;
    const mainVerticalRoadRatio = 0.14;
    // Height ratios
    const slotHRatio = 0.08; // Adjusted to fit 5 rows + gap in 0.88 gridH
    const horizontalGapRatio = 0.20; // Re-adjusted gap for better separation

    final slotW = gridW * slotWRatio;
    final internalLaneW = gridW * internalLaneRatio;
    final mainVRoadW = gridW * mainVerticalRoadRatio;
    final slotH = gridH * slotHRatio;
    final horizontalGap = gridH * horizontalGapRatio;

    const verticalGap = 6.0;

    List<Widget> positioned = [];
    for (final slot in slots) {
      final globalCol = slot.gridPosition.dx.toInt();
      final globalRow = slot.gridPosition.dy.toInt();

      // Calculate X
      double x = startX;
      if (globalCol == 0) {
        x = startX;
      } else if (globalCol == 1) {
        x = startX + slotW + internalLaneW;
      } else if (globalCol == 2) {
        x = startX + 2 * slotW + internalLaneW + mainVRoadW;
      } else if (globalCol == 3) {
        x = startX + 3 * slotW + 2 * internalLaneW + mainVRoadW;
      }

      // Calculate Y
      double y = topPad;
      if (globalRow < 5) {
        y = topPad + globalRow * slotH;
      } else {
        // Shift lower blocks down by the gap amount
        y = topPad + globalRow * slotH + horizontalGap;
      }

      positioned.add(
        Positioned(
          left: x,
          top: y + verticalGap / 2,
          width: slotW,
          height: slotH - verticalGap,
          child: ParkingSlotWidget(
            slot: slot,
            isSelected: selectedSlotId == slot.id,
            pulseAnimation: _pulseController,
            onTap: () => _onSlotTap(slot.id),
            onLongPress: () => _toggleSlotStatus(slot.id),
          ),
        ),
      );
    }

    return Stack(children: positioned);
  }

  Widget _buildEntranceExit(double w, double h) {
    return Stack(
      children: [
        // ENTRANCE — top
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: _gateLabel('▼  ENTRANCE', const Color(0xFF005A2F)),
          ),
        ),
        // EXIT — bottom
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(child: _gateLabel('EXIT  ▼', const Color(0xFFFF5252))),
        ),
      ],
    );
  }

  Widget _gateLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
