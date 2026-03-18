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

  Future<String?> showUnitPickerDialog(
    BuildContext context,
    List<RealParkingUnit> units,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Parking Unit"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Builder(
              builder: (context) {
                if (units.isEmpty) {
                  return const Center(child: Text("No units available"));
                }
                return ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    final unit = units[index];

                    return ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text(unit.label),
                      subtitle: Text(unit.mac),
                      trailing: Text(
                        unit.status,
                        style: TextStyle(
                          color: unit.status == "free"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirm"),
                              content: Text("Use parking unit ${unit.label}?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Confirm"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          Navigator.pop(context, unit.mac);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Close"),
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
          title: const Text("Confirmation"),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: Center(
              child: Center(
                child: Text(
                  'Do you want to delete this unit?',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
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
