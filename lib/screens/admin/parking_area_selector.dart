import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart' hide NavigationMode;
import 'package:smart_parking_ble/screens/admin/real_parking_slot.dart';
import 'package:smart_parking_ble/screens/admin/slot_configuration_widget.dart';
import '../../model/slot.dart';
import 'asphalt_painter.dart';

class ParkingScreenAdmin extends StatefulWidget {
  const ParkingScreenAdmin({super.key});

  @override
  State<ParkingScreenAdmin> createState() => _ParkingScreenAdminState();
}

class _ParkingScreenAdminState extends State<ParkingScreenAdmin>
    with TickerProviderStateMixin {
  late List<ParkingSlot> slots;
  String? selectedSlotId;
  NavigationMode navMode = NavigationMode.fromEntrance;
  bool slotsInitialized = false;

  // Animation controllers
  late AnimationController _pathAnimController;
  late AnimationController _carMoveController;
  late AnimationController _pulseController;

  late Animation<double> _carProgress;
  bool isLoading = false;

  List<RealParkingUnit> realUnits = [];

  @override
  void initState() {
    super.initState();
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
    _initSlots();
  }

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

  List<RealParkingUnit> getAllConfiguredSlotsIds() {
    return realUnits.where((e) => e.linkedTo.isNotEmpty).toList();
  }

  Future _initSlots() async {
    realUnits = await getAllRealUnits();
    final List<RealParkingUnit> configuredParkingSLots =
        getAllConfiguredSlotsIds();
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
            status: ParkingStatus.available,
            gridPosition: Offset(globalCol.toDouble(), globalRow.toDouble()),
            type: (i == 4) ? ParkingType.disablePerson : ParkingType.normal,
            linkedToDevice: configuredParkingSLots
                .firstWhereOrNull((e) => e.label == id)
                ?.mac,
          ),
        );
      }
    }

    setState(() {
      slotsInitialized = true;
    });
  }

  void _onSlotTap(String id) async {
    if (selectedSlotId == id) {
      selectedSlotId = null;
    } else {
      selectedSlotId = id;
      final bool isConfigured =
          realUnits
              .firstWhereOrNull((e) => e.label == id)
              ?.linkedTo
              .isNotEmpty ??
          false;

      if (isConfigured) {
        final confirmed = await showDeleteConfirmationDialog(context);
        if (confirmed == true) {
          setState(() => isLoading = true);
          await deleteRealUnitConfigurationOnFirebase(id);
          await _initSlots();
          setState(() => isLoading = false);
        }
      } else {
        final selectedMac = await showUnitPickerDialog(
          context,
          realUnits.where((u) => u.linkedTo.isEmpty).toList(),
        );
        if (selectedMac != null) {
          setState(() => isLoading = true);
          await updateRealUnitConfigurationOnFirebase(selectedMac, id);
          await _initSlots();
          setState(() => isLoading = false);
        }
      }
    }
    setState(() {});
  }

  Future updateRealUnitConfigurationOnFirebase(
    String mac,
    String slotId,
  ) async {
    final ref = FirebaseDatabase.instance.ref('units/$mac');
    await ref.update({'linkedTo': mac, 'label': slotId});
  }

  Future deleteRealUnitConfigurationOnFirebase(String slotId) async {
    final mac = realUnits.firstWhereOrNull((e) => e.label == slotId)?.mac;
    if (mac == null) return;
    final ref = FirebaseDatabase.instance.ref('units/$mac');
    await ref.update({'linkedTo': '', 'label': 'not Configured'});
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

  // — Color palette —
  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  Future<String?> showUnitPickerDialog(
    BuildContext context,
    List<RealParkingUnit> units,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [g2, g3],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Select Parking Unit",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Builder(
              builder: (context) {
                if (units.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.bluetooth_disabled_rounded,
                            size: 28,
                            color: g2.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No units available",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: units.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final unit = units[index];

                    return GestureDetector(
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              title: const Text(
                                "Confirm",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: darkText,
                                ),
                              ),
                              content: Text(
                                "Link slot to parking unit ${unit.label}?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: mutedText.withOpacity(0.9),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: mutedText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: g2,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text(
                                    "Confirm",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          Navigator.pop(context, unit.mac);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: unit.status == "free"
                              ? cardGreen
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: unit.status == "free"
                                ? g3.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: unit.status == "free"
                                      ? [g2, g3]
                                      : [Colors.grey, Colors.grey.shade600],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.bluetooth_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    unit.label,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    unit.mac,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: mutedText.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: unit.status == "free"
                                    ? const Color(0xFF40C074).withOpacity(0.15)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                unit.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: unit.status == "free"
                                      ? const Color(0xFF40C074)
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context, null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3232).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFc0392b),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Unlink Unit",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to unlink this parking unit from the slot?',
            style: TextStyle(
              fontSize: 14,
              color: mutedText.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFc0392b),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text(
                "Unlink",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: slotsInitialized && !isLoading
                  ? _buildParkingLot()
                  : Center(child: const CircularProgressIndicator()),
            ),
          ],
        ),
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
                      painter: AsphaltPainter(
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
          child: ConfigurationParkingSlotWidget(
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
