import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart' hide NavigationMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_parking_ble/screens/find_parking/slot_widget.dart';
import '../../model/profile.dart';
import '../../providers/profile.dart';
import '../admin/real_parking_slot.dart';
import '../parking_area/model/slot.dart';
import 'asphalt_paint.dart';
import 'ble_scanner_widget.dart';

class NavigateToParkingScreen extends StatefulWidget {
  const NavigateToParkingScreen({super.key, required this.slotId});

  final String slotId;

  @override
  State<NavigateToParkingScreen> createState() =>
      _NavigateToParkingScreenState();
}

class _NavigateToParkingScreenState extends State<NavigateToParkingScreen>
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

  List<RealParkingUnit> realUnits = [];
  bool slotsInitialized = false;
  double? distance;

  Future<List<RealParkingUnit>> getAllRealUnits() async {
    final ref = FirebaseDatabase.instance.ref('units');
    final snapshot = await ref.get();

    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.entries.map((e) {
      return RealParkingUnit.fromJson(
        e.key.toString(),
        Map<String, dynamic>.from(e.value),
      );
    }).toList();
  }

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

  void moveCarTo(double target) {
    _carMoveController.animateTo(
      target.clamp(0.0, 1.0),
      duration: const Duration(milliseconds: 500),
    );
  }

  Future _initSlots() async {
    realUnits = await getAllRealUnits();
    slots = [];
    selectedSlotId = widget.slotId;
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
            status: ParkingStatus.available,
            gridPosition: Offset(globalCol.toDouble(), globalRow.toDouble()),
            type: (i == 4) ? ParkingType.disablePerson : ParkingType.normal,
          ),
        );
      }
    }
    setState(() {
      slotsInitialized = true;
    });
  }

  void _onSlotTap(String id) {
    // setState(() {
    //   if (selectedSlotId == id) {
    //     selectedSlotId = null;
    //     _carMoveController.reset();
    //   } else {
    //     selectedSlotId = id;
    //     _carMoveController.forward(from: 0);
    //   }
    // });
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
        child: slotsInitialized
            ? Column(
                children: [
                  // _buildHeader(),
                  BleProximityWidget(
                    targetDeviceName: realUnits
                        .where((e) => e.label == widget.slotId)
                        .first
                        .mac,
                    onDistanceUpdate: (double? meters) {
                      if (meters == null) return;
                      double mapped = 0.85 * (1 - (meters / 20));
                      moveCarTo(mapped);
                    },
                  ),
                  Expanded(child: _buildParkingLot()),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final profileCtrl = ref.watch(
                            profileProvider.notifier,
                          );
                          return ElevatedButton(
                            onPressed: () async {
                              final profile = ref.read(profileProvider);
                              final p = CurrentParking(
                                parkedAt: DateTime.now(),
                                parkingId: widget.slotId,
                                parkingAreaId: 'P1',
                              );
                              await updateProfileToFirebase(
                                profile!.uid ?? 'tt',
                                p,
                              );
                              profileCtrl.update(currentParking: p);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2D6A4F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text('Save My Parking'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future updateProfileToFirebase(String uid, CurrentParking p) async {
    FirebaseFirestore.instance.collection('profiles').doc(uid).update({
      'current_parking': p.toJson(),
    });
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
                      painter: ParkingAsphalt2Painter(
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
          child: NavigateParkingSlotWidget(
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
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: _gateLabel('▼  ENTRANCE', const Color(0xFF005A2F)),
          ),
        ),
        // EXIT — bottom
        Positioned(
          bottom: 0,
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
