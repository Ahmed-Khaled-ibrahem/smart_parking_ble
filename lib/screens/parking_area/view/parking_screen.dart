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
    const ids = ['A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3'];
    slots = List.generate(9, (i) {
      final col = i % 3;
      final row = i ~/ 3;
      return ParkingSlot(
        id: ids[i],
        status: (i == 1 || i == 4 || i == 7)
            ? ParkingStatus.occupied
            : ParkingStatus.available,
        gridPosition: Offset(col.toDouble(), row.toDouble()),
      );
    });
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zone Alpha — Level B1',
                style: TextStyle(fontSize: 12, letterSpacing: 1.2),
              ),
            ],
          ),
          const Spacer(),
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
    // Slot grid sits in the upper portion, leaving room for entrance/exit labels
    final topPad = h * 0.10;
    final bottomPad = h * 0.10;
    final gridH = h - topPad - bottomPad;
    final gridW = w * 0.92;
    final startX = (w - gridW) / 2;

    // 3 columns with a lane in the middle → col 0, lane, col1, lane, col2
    // We split gridW into: slot | lane | slot | lane | slot
    const laneRatio = 0.10;
    const slotRatio = (1 - laneRatio * 2) / 3;
    final slotW = gridW * slotRatio;
    final laneW = gridW * laneRatio;

    // 3 rows with a horizontal lane between → row0 lane row1 lane row2
    const hLaneRatio = 0.08;
    const rowRatio = (1 - hLaneRatio * 2) / 3;
    final slotH = gridH * rowRatio;
    final laneH = gridH * hLaneRatio;

    List<Widget> positioned = [];
    for (final slot in slots) {
      final col = slot.gridPosition.dx.toInt();
      final row = slot.gridPosition.dy.toInt();

      final x = startX + col * (slotW + laneW);
      final y = topPad + row * (slotH + laneH);

      positioned.add(
        Positioned(
          left: x,
          top: y,
          width: slotW,
          height: slotH,
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
